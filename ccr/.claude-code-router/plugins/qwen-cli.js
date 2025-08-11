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
    try {
      this.oauth_creds = require(OAUTH_FILE);
    } catch { }
  }

  async transformRequestIn(request, provider) {
    if (this.oauth_creds && this.oauth_creds.expiry_date < +new Date()) {
      await this.refreshToken(this.oauth_creds.refresh_token);
    }

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
    const isStreaming = response.headers
      .get("Content-Type")
      ?.includes("text/event-stream");

    if (isStreaming) {
      if (!response.body) {
        return response;
      }

      const decoder = new TextDecoder();
      const encoder = new TextEncoder();

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
              // Transform the chunk to the expected format
              const choices = chunk.choices.map((choice) => {
                const delta = choice.delta;
                if (delta.role === "assistant") {
                  delta.role = "model";
                }
                return {
                  ...choice,
                  delta,
                };
              });
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
        throw new Error(data.error_description || "Failed to refresh token");
      }

      data.expiry_date =
        new Date().getTime() + data.expires_in * 1000 - 1000 * 60;
      data.refresh_token = data.refresh_token || refresh_token; // Use the new refresh token if provided
      delete data.expires_in;

      this.oauth_creds = data;
      await fs.writeFile(OAUTH_FILE, JSON.stringify(data, null, 2));
      log("Qwen token refreshed successfully");
    } catch (error) {
      log("Error refreshing Qwen token:", error.message);
      throw error;
    }
  }
}

module.exports = QwenCLITransformer;
