const { log } = require("claude-code-router");
log("Loading QwenCLITransformer plugin");

const os = require("os");
const path = require("path");
const fs = require("fs/promises");

const OAUTH_FILE = path.join(os.homedir(), ".qwen", "oauth_creds.json");

const QWEN_TOKEN_ENDPOINT = "https://portal.qwen.ai/api/v1/token/refresh";
const QWEN_CLIENT_ID = "gemini-web-app";

class QwenCLITransformer {
  name = "qwen-cli";

  constructor(options) {
    this.options = options;
    this.refreshPromise = null; // Track ongoing refresh operations
    try {
      this.oauth_creds = require(OAUTH_FILE);
    } catch { }
  }

  async transformRequestIn(request, provider) {
    // Ensure we have valid credentials
    await this.ensureValidToken();

    const messages = request.messages.map((message) => {
      const { role, content, tool_calls } = message;
      const openAIRole = role === "model" ? "assistant" : role;
      return {
        role: openAIRole,
        content,
        tool_calls,
      };
    });

    const tools = request.tools?.map((tool) => ({
      type: "function",
      function: tool.function,
    }));

    const body = {
      model: request.model,
      messages,
      tools,
      stream: request.stream,
    };

    const DEFAULT_QWEN_BASE_URL =
      "https://dashscope.aliyuncs.com/compatible-mode/v1";
    let qwenEndpoint = this.oauth_creds?.resource_url || DEFAULT_QWEN_BASE_URL;
    if (!qwenEndpoint.startsWith("http")) {
      qwenEndpoint = "https://" + qwenEndpoint;
    }
    if (!qwenEndpoint.endsWith("/v1")) {
      qwenEndpoint = qwenEndpoint + "/v1";
    }
    const url = new URL(qwenEndpoint + "/chat/completions");

    return {
      body: body,
      config: {
        url: url,
        method: "POST",
        headers: {
          Authorization: `Bearer ${this.oauth_creds.access_token}`,
          "Content-Type": "application/json",
        },
      },
    };
  }

  async transformResponseOut(response) {
    // Check for authentication errors in non-streaming responses
    if (this.isAuthError(response)) {
      log("Authentication error detected in response");
      
      // For non-streaming responses, we can check the body
      const contentType = response.headers.get("Content-Type");
      if (contentType?.includes("application/json")) {
        try {
          // Clone the response so we don't consume the original
          const clonedResponse = response.clone();
          const errorData = await clonedResponse.json();
          
          // Log the error details
          log("Auth error details:", errorData.error || errorData.error_description || "Unknown error");
          
          // Attempt to refresh the token
          try {
            await this.forceRefreshToken();
            log("Token refreshed successfully after auth error");
          } catch (refreshError) {
            log("Failed to refresh token:", refreshError.message);
          }
        } catch (e) {
          // If we can't parse the response, just proceed
          log("Could not parse error response");
        }
      }
    }

    const isStreaming = response.headers
      .get("Content-Type")
      ?.includes("text/event-stream");

    if (isStreaming) {
      if (!response.body) {
        return response;
      }

      const decoder = new TextDecoder();
      const encoder = new TextEncoder();
      const self = this; // Capture this context

      const processLine = (line, controller) => {
        if (line.startsWith("data: ")) {
          const chunkStr = line.slice(6).trim();
          if (chunkStr === "[DONE]") {
            controller.enqueue(encoder.encode("data: [DONE]\n\n"));
            return;
          }
          if (chunkStr) {
            try {
              let chunk = JSON.parse(chunkStr);
              
              // Check for authentication errors in streaming response
              if (chunk.error) {
                const errorCode = chunk.error.code || chunk.error.type;
                const errorMessage = chunk.error.message || chunk.error.error_description || "";
                
                if (self.isStreamAuthError(errorCode, errorMessage)) {
                  log("Authentication error in stream:", errorMessage);
                  // Attempt to refresh token for next request
                  self.forceRefreshToken().catch(err => 
                    log("Failed to refresh token in stream:", err.message)
                  );
                }
              }
              
              // Transform the chunk to the expected format
              const choices = chunk.choices?.map((choice) => {
                const delta = choice.delta;
                if (delta.role === "assistant") {
                  delta.role = "model";
                }
                return {
                  ...choice,
                  delta,
                };
              }) || [];
              chunk.choices = choices;
              controller.enqueue(
                encoder.encode(`data: ${JSON.stringify(chunk)}\n\n`),
              );
            } catch (error) {
              log("Error parsing Qwen stream chunk", chunkStr, error.message);
            }
          }
        }
      };

      const stream = new ReadableStream({
        async start(controller) {
          const reader = response.body.getReader();
          let buffer = "";
          try {
            while (true) {
              const { done, value } = await reader.read();
              if (done) {
                if (buffer) {
                  processLine(buffer, controller);
                }
                break;
              }

              buffer += decoder.decode(value, { stream: true });
              const lines = buffer.split("\n");

              buffer = lines.pop() || "";

              for (const line of lines) {
                processLine(line, controller);
              }
            }
          } catch (error) {
            controller.error(error);
          } finally {
            controller.close();
          }
        },
      });

      return new Response(stream, {
        status: response.status,
        statusText: response.statusText,
        headers: response.headers,
      });
    } else if (
      response.headers.get("Content-Type")?.includes("application/json")
    ) {
      const json = await response.json();
      const choices = json.choices.map((choice) => {
        const message = choice.message;
        if (message.role === "assistant") {
          message.role = "model";
        }
        return {
          ...choice,
          message,
        };
      });
      json.choices = choices;
      return new Response(JSON.stringify(json), response);
    }

    return response;
  }

  /**
   * Ensure we have a valid token before making requests
   */
  async ensureValidToken() {
    if (!this.oauth_creds) {
      throw new Error("No Qwen credentials found. Please authenticate first.");
    }

    // Check if token is expired or about to expire (with 5 minute buffer)
    const now = Date.now();
    const expiryBuffer = 5 * 60 * 1000; // 5 minutes
    
    if (this.oauth_creds.expiry_date < now + expiryBuffer) {
      await this.getValidToken();
    }
  }

  /**
   * Get a valid access token, refreshing if necessary
   */
  async getValidToken() {
    // If there's already a refresh in progress, wait for it
    if (this.refreshPromise) {
      return this.refreshPromise;
    }

    // Start a new refresh operation
    this.refreshPromise = this.performTokenRefresh();
    
    try {
      await this.refreshPromise;
    } finally {
      this.refreshPromise = null;
    }
  }

  /**
   * Force refresh the access token
   */
  async forceRefreshToken() {
    if (this.refreshPromise) {
      return this.refreshPromise;
    }

    this.refreshPromise = this.performTokenRefresh();
    
    try {
      await this.refreshPromise;
    } finally {
      this.refreshPromise = null;
    }
  }

  /**
   * Perform the actual token refresh
   */
  async performTokenRefresh() {
    if (!this.oauth_creds || !this.oauth_creds.refresh_token) {
      throw new Error("No refresh token available. Please re-authenticate.");
    }

    return this.refreshToken(this.oauth_creds.refresh_token);
  }

  /**
   * Check if a response indicates an authentication error
   */
  isAuthError(response) {
    if (!response) return false;
    
    const status = response.status;
    if (status === 400 || status === 401 || status === 403) {
      return true;
    }

    // Check for specific error messages in response body if available
    const contentType = response.headers.get("Content-Type");
    if (contentType?.includes("application/json") && response.bodyUsed === false) {
      // Note: We can't check the body here as it would consume the stream
      // The status code check above should be sufficient
    }

    return false;
  }

  /**
   * Check if a streaming error is an authentication error
   */
  isStreamAuthError(errorCode, errorMessage) {
    if (!errorCode && !errorMessage) return false;
    
    const code = String(errorCode).toLowerCase();
    const message = String(errorMessage).toLowerCase();
    
    return (
      code === 'unauthorized' ||
      code === 'forbidden' ||
      code === 'invalid_api_key' ||
      code === 'invalid_access_token' ||
      code === 'token_expired' ||
      code === 'authentication_error' ||
      code === 'permission_denied' ||
      message.includes('unauthorized') ||
      message.includes('forbidden') ||
      message.includes('invalid api key') ||
      message.includes('invalid access token') ||
      message.includes('token expired') ||
      message.includes('authentication') ||
      message.includes('access denied') ||
      (message.includes('token') && message.includes('expired'))
    );
  }

  async refreshToken(refresh_token) {
    log("Refreshing Qwen token");
    try {
      const response = await fetch(QWEN_TOKEN_ENDPOINT, {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          client_id: QWEN_CLIENT_ID,
          refresh_token: refresh_token,
          grant_type: "refresh_token",
        }),
      });

      const data = await response.json();

      if (!response.ok) {
        const errorMsg = data.error_description || data.error || "Failed to refresh token";
        log("Token refresh failed:", errorMsg);
        
        // If refresh token is invalid, clear credentials
        if (data.error === "invalid_grant" || response.status === 400) {
          log("Refresh token is invalid, clearing credentials");
          this.oauth_creds = null;
          try {
            await fs.unlink(OAUTH_FILE);
          } catch (e) {
            // Ignore file deletion errors
          }
        }
        
        throw new Error(errorMsg);
      }

      // Calculate expiry date with a small buffer to account for clock skew
      data.expiry_date = Date.now() + (data.expires_in * 1000) - (60 * 1000);
      
      // Use the new refresh token if provided, otherwise keep the old one
      data.refresh_token = data.refresh_token || refresh_token;
      
      // Store additional metadata if provided
      if (data.resource_url) {
        // Resource URL is already in the response
      }
      
      delete data.expires_in;

      this.oauth_creds = data;
      
      // Ensure directory exists
      const dir = path.dirname(OAUTH_FILE);
      try {
        await fs.mkdir(dir, { recursive: true });
      } catch (e) {
        // Directory might already exist
      }
      
      await fs.writeFile(OAUTH_FILE, JSON.stringify(data, null, 2));
      log("Qwen token refreshed successfully");
      
      return data.access_token;
    } catch (error) {
      log("Error refreshing Qwen token:", error.message);
      this.refreshPromise = null; // Clear the promise on error
      throw error;
    }
  }
}

module.exports = QwenCLITransformer;
