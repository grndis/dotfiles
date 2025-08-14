const os = require("os");
const path = require("path");
const fs = require("fs/promises");

// File System Configuration
const QWEN_DIR = '.qwen';
const QWEN_CREDENTIAL_FILENAME = 'oauth_creds.json';
const QWEN_MULTI_ACCOUNT_PREFIX = 'oauth_creds_';
const QWEN_MULTI_ACCOUNT_SUFFIX = '.json';
const OAUTH_FILE = path.join(os.homedir(), QWEN_DIR, QWEN_CREDENTIAL_FILENAME);

const QWEN_TOKEN_ENDPOINT = "https://chat.qwen.ai/api/v1/oauth2/token";
const QWEN_CLIENT_ID = "f0304373b74a44d2b584a3fb70ca9e56";
const TOKEN_REFRESH_BUFFER_MS = 30 * 1000; // 30 seconds

function objectToUrlEncoded(data) {
  return Object.keys(data)
    .map((key) => `${encodeURIComponent(key)}=${encodeURIComponent(data[key])}`)
    .join("&");
}

class QwenCLITransformer {
  name = "qwen-cli";

  constructor(options) {
    this.options = options;
    this.refreshPromise = null; // Track ongoing refresh operations
    this.qwenDir = path.join(os.homedir(), QWEN_DIR);
    this.credentialsPath = OAUTH_FILE;
    this.credentials = null;
    this.accounts = new Map(); // For multi-account support
    this.currentAccountIndex = 0; // For round-robin account selection
    this.requestCount = new Map(); // Track requests per account
    this.lastResetDate = new Date().toISOString().split('T')[0]; // Track last reset date (UTC)
    this.requestCountFile = path.join(this.qwenDir, 'request_counts.json');
    
    try {
      this.oauth_creds = require(OAUTH_FILE);
    } catch { }
  }

  /**
   * Load all multi-account credentials
   * @returns {Promise<Map>} Map of account IDs to credentials
   */
  async loadAllAccounts() {
    try {
      // Clear existing accounts
      this.accounts.clear();
      
      // Ensure directory exists
      try {
        await fs.mkdir(this.qwenDir, { recursive: true });
      } catch (e) {
        // Directory might already exist
      }
      
      // Read directory to find all credential files
      const files = await fs.readdir(this.qwenDir);
      
      // Filter for multi-account credential files
      const accountFiles = files.filter(file => 
        file.startsWith(QWEN_MULTI_ACCOUNT_PREFIX) && 
        file.endsWith(QWEN_MULTI_ACCOUNT_SUFFIX) &&
        file !== QWEN_CREDENTIAL_FILENAME
      );
      
      // Load each account
      for (const file of accountFiles) {
        try {
          const accountPath = path.join(this.qwenDir, file);
          const credentialsData = await fs.readFile(accountPath, 'utf8');
          const credentials = JSON.parse(credentialsData);
          
          // Extract account ID from filename
          const accountId = file.substring(
            QWEN_MULTI_ACCOUNT_PREFIX.length,
            file.length - QWEN_MULTI_ACCOUNT_SUFFIX.length
          );
          
          this.accounts.set(accountId, credentials);
        } catch (error) {
          console.warn(`Failed to load account from ${file}:`, error.message);
        }
      }
      
      // Also load the default account if it exists
      try {
        const defaultCredentials = await this.loadCredentials();
        if (defaultCredentials) {
          this.accounts.set('default', defaultCredentials);
        }
      } catch (error) {
        console.warn('Failed to load default account:', error.message);
      }
      
      return this.accounts;
    } catch (error) {
      console.warn('Failed to load multi-account credentials:', error.message);
      return this.accounts;
    }
  }

  async loadCredentials() {
    if (this.credentials) {
      return this.credentials;
    }
    try {
      const credentialsData = await fs.readFile(this.credentialsPath, 'utf8');
      this.credentials = JSON.parse(credentialsData);
      return this.credentials;
    } catch (error) {
      return null;
    }
  }

  async saveCredentials(credentials, accountId = null) {
    try {
      const credString = JSON.stringify(credentials, null, 2);
      
      if (accountId) {
        // Save to specific account file
        const accountFilename = `${QWEN_MULTI_ACCOUNT_PREFIX}${accountId}${QWEN_MULTI_ACCOUNT_SUFFIX}`;
        const accountPath = path.join(this.qwenDir, accountFilename);
        await fs.writeFile(accountPath, credString);
        
        // Update accounts map
        this.accounts.set(accountId, credentials);
      } else {
        // Save to default credentials file
        await fs.writeFile(this.credentialsPath, credString);
        this.credentials = credentials;
      }
    } catch (error) {
      console.error('Error saving credentials:', error.message);
    }
  }

  isTokenValid(credentials) {
    if (!credentials || !credentials.expiry_date) {
      return false;
    }
    return Date.now() < credentials.expiry_date - TOKEN_REFRESH_BUFFER_MS;
  }

  /**
   * Get a list of all account IDs
   * @returns {string[]} Array of account IDs
   */
  getAccountIds() {
    return Array.from(this.accounts.keys());
  }

  /**
   * Get credentials for a specific account
   * @param {string} accountId - The account ID
   * @returns {Object|null} The credentials or null if not found
   */
  getAccountCredentials(accountId) {
    return this.accounts.get(accountId) || null;
  }


  /**
   * Get the next available account for rotation
   * @returns {Object|null} Object with {accountId, credentials} or null if no accounts available
   */
  async getNextAccount() {
    // Load all accounts if not already loaded
    if (this.accounts.size === 0) {
      await this.loadAllAccounts();
    }
    
    const accountIds = this.getAccountIds();
    
    if (accountIds.length === 0) {
      return null;
    }
    
    // Use round-robin selection
    const accountId = accountIds[this.currentAccountIndex];
    const credentials = this.getAccountCredentials(accountId);
    
    // Update index for next call
    this.currentAccountIndex = (this.currentAccountIndex + 1) % accountIds.length;
    
    return { accountId, credentials };
  }

  /**
   * Peek at the next account without consuming it
   * @returns {Object|null} Object with {accountId, credentials} or null if no accounts available
   */
  peekNextAccount() {
    // Load all accounts if not already loaded
    if (this.accounts.size === 0) {
      // Note: This is a synchronous method, so we can't load accounts here
      // The accounts should already be loaded before calling this method
      return null;
    }
    
    const accountIds = this.getAccountIds();
    
    if (accountIds.length === 0) {
      return null;
    }
    
    // Use round-robin selection without updating index
    const accountId = accountIds[this.currentAccountIndex];
    const credentials = this.getAccountCredentials(accountId);
    
    return { accountId, credentials };
  }

  /**
   * Check if an account has valid credentials
   * @param {string} accountId - The account ID
   * @returns {boolean} True if the account has valid credentials
   */
  isAccountValid(accountId) {
    const credentials = this.getAccountCredentials(accountId);
    return credentials && this.isTokenValid(credentials);
  }

  /**
   * Load request counts from disk
   */
  async loadRequestCounts() {
    try {
      const data = await fs.readFile(this.requestCountFile, 'utf8');
      const counts = JSON.parse(data);
      
      // Restore last reset date
      if (counts.lastResetDate) {
        this.lastResetDate = counts.lastResetDate;
      }
      
      // Restore request counts
      if (counts.requests) {
        for (const [accountId, count] of Object.entries(counts.requests)) {
          this.requestCount.set(accountId, count);
        }
      }
      
      // Reset counts if we've crossed into a new UTC day
      this.resetRequestCountsIfNeeded();
    } catch (error) {
      // File doesn't exist or is invalid, start with empty counts
      this.resetRequestCountsIfNeeded();
    }
  }

  /**
   * Save request counts to disk
   */
  async saveRequestCounts() {
    try {
      const counts = {
        lastResetDate: this.lastResetDate,
        requests: Object.fromEntries(this.requestCount)
      };
      await fs.writeFile(this.requestCountFile, JSON.stringify(counts, null, 2));
    } catch (error) {
      console.warn('Failed to save request counts:', error.message);
    }
  }

  /**
   * Reset request counts if we've crossed into a new UTC day
   */
  resetRequestCountsIfNeeded() {
    const today = new Date().toISOString().split('T')[0];
    if (today !== this.lastResetDate) {
      this.requestCount.clear();
      this.lastResetDate = today;
      console.log('Request counts reset for new UTC day');
      this.saveRequestCounts();
    }
  }

  /**
   * Increment request count for an account
   * @param {string} accountId - The account ID
   */
  async incrementRequestCount(accountId) {
    this.resetRequestCountsIfNeeded();
    const currentCount = this.requestCount.get(accountId) || 0;
    this.requestCount.set(accountId, currentCount + 1);
    await this.saveRequestCounts();
  }

  /**
   * Get request count for an account
   * @param {string} accountId - The account ID
   * @returns {number} The request count
   */
  getRequestCount(accountId) {
    this.resetRequestCountsIfNeeded();
    return this.requestCount.get(accountId) || 0;
  }

  async transformResponseOut(response) {
    // Check for authentication errors in non-streaming responses
    if (this.isAuthError(response)) {
      // For non-streaming responses, we can check the body
      const contentType = response.headers.get("Content-Type");
      if (contentType?.includes("application/json")) {
        try {
          // Clone the response so we don't consume the original
          const clonedResponse = response.clone();
          const errorData = await clonedResponse.json();

          // Attempt to refresh the token
          try {
            // For backward compatibility, we'll try to refresh with default account
            // In multi-account scenarios, the specific account should be handled in transformRequestIn
            await this.forceRefreshToken();
          } catch (refreshError) { }
        } catch (e) {
          // If we can't parse the response, just proceed
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
                const errorMessage =
                  chunk.error.message || chunk.error.error_description || "";

                if (self.isStreamAuthError(errorCode, errorMessage)) {
                  // Attempt to refresh token for next request
                  // For backward compatibility, we'll try to refresh with default account
                  // In multi-account scenarios, the specific account should be handled in transformRequestIn
                  self.forceRefreshToken();
                }
              }

              // Transform the chunk to the expected format
              const choices =
                chunk.choices?.map((choice) => {
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
            } catch (error) { }
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
    // This method is kept for backward compatibility but multi-account logic
    // is now handled in transformRequestIn
    await this.loadCredentials();
    if (!this.oauth_creds) {
      throw new Error("No Qwen credentials found. Please authenticate first.");
    }

    // Check if token is expired or about to expire (with 5 minute buffer)
    const now = Date.now();
    const expiryBuffer = 5 * 60 * 1000; // 5 minutes

    if (
      !this.oauth_creds.expiry_date ||
      this.oauth_creds.expiry_date < now + expiryBuffer
    ) {
      await this.getValidToken();
    }
  }

  /**
   * Get a valid access token, refreshing if necessary
   * @param {string} accountId - Optional account ID to use
   */
  async getValidToken(accountId = null) {
    // If there's already a refresh in progress, wait for it
    if (this.refreshPromise) {
      return this.refreshPromise;
    }

    try {
      let credentials;
      
      if (accountId) {
        // Get credentials for specific account
        credentials = this.getAccountCredentials(accountId);
        if (!credentials) {
          // Load all accounts if not already loaded
          await this.loadAllAccounts();
          credentials = this.getAccountCredentials(accountId);
        }
        
        // Special handling for 'default' account
        if (accountId === 'default' && !credentials) {
          // Use default credentials
          credentials = await this.loadCredentials();
        }
      } else {
        // Use default credentials
        credentials = await this.loadCredentials();
      }

      if (!credentials) {
        if (accountId) {
          throw new Error(`No credentials found for account ${accountId}. Please authenticate this account first.`);
        } else {
          throw new Error('No credentials found. Please authenticate with Qwen CLI first.');
        }
      }

      // Check if token is valid
      if (this.isTokenValid(credentials)) {
        console.log(accountId ? 
          `\x1b[32mUsing valid Qwen access token for account ${accountId}\x1b[0m` : 
          '\x1b[32mUsing valid Qwen access token\x1b[0m');
        return credentials.access_token;
      } else {
        console.log(accountId ? 
          `\x1b[33mQwen access token for account ${accountId} expired or expiring soon, refreshing...\x1b[0m` : 
          '\x1b[33mQwen access token expired or expiring soon, refreshing...\x1b[0m');
      }

      // Token needs refresh, start refresh operation
      this.refreshPromise = this.performTokenRefresh(credentials, accountId);
      
      try {
        const newCredentials = await this.refreshPromise;
        return newCredentials.access_token;
      } finally {
        this.refreshPromise = null;
      }
    } catch (error) {
      this.refreshPromise = null;
      throw error;
    }
  }

  /**
   * Force refresh the access token
   * @param {string} accountId - Optional account ID to refresh
   */
  async forceRefreshToken(accountId = null) {
    if (this.refreshPromise) {
      return this.refreshPromise;
    }

    // Load credentials for the specified account
    let credentials;
    if (accountId) {
      credentials = this.getAccountCredentials(accountId);
      if (!credentials) {
        await this.loadAllAccounts();
        credentials = this.getAccountCredentials(accountId);
      }
    } else {
      credentials = await this.loadCredentials();
    }

    if (!credentials || !credentials.refresh_token) {
      throw new Error("No refresh token available. Please re-authenticate.");
    }

    this.refreshPromise = this.performTokenRefresh(credentials, accountId);

    try {
      await this.refreshPromise;
    } finally {
      this.refreshPromise = null;
    }
  }

  /**
   * Perform the actual token refresh
   * @param {Object} credentials - The credentials to refresh
   * @param {string} accountId - Optional account ID
   */
  async performTokenRefresh(credentials, accountId = null) {
    if (!credentials || !credentials.refresh_token) {
      throw new Error("No refresh token available. Please re-authenticate.");
    }

    return this.refreshToken(credentials.refresh_token, accountId);
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
    if (
      contentType?.includes("application/json") &&
      response.bodyUsed === false
    ) {
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
      code === "unauthorized" ||
      code === "forbidden" ||
      code === "invalid_api_key" ||
      code === "invalid_access_token" ||
      code === "token_expired" ||
      code === "authentication_error" ||
      code === "permission_denied" ||
      message.includes("unauthorized") ||
      message.includes("forbidden") ||
      message.includes("invalid api key") ||
      message.includes("invalid access token") ||
      message.includes("token expired") ||
      message.includes("authentication") ||
      message.includes("access denied") ||
      (message.includes("token") && message.includes("expired"))
    );
  }

  async refreshToken(refresh_token, accountId = null) {
    try {
      const bodyData = {
        grant_type: "refresh_token",
        refresh_token: refresh_token,
        client_id: QWEN_CLIENT_ID,
      };

      const response = await fetch(QWEN_TOKEN_ENDPOINT, {
        method: "POST",
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          Accept: "application/json",
        },
        body: objectToUrlEncoded(bodyData),
      });

      const responseText = await response.text();

      if (!response.ok) {
        let errorMsg = `Token refresh failed with status: ${response.status}`;
        try {
          const errorData = JSON.parse(responseText);
          errorMsg =
            errorData.error_description || errorData.error || responseText;
        } catch (e) {
          errorMsg = `${errorMsg} - ${responseText}`;
        }

        if (response.status === 400) {
          // Remove invalid credentials
          if (accountId) {
            this.accounts.delete(accountId);
            // Remove the account file
            try {
              const accountFilename = `${QWEN_MULTI_ACCOUNT_PREFIX}${accountId}${QWEN_MULTI_ACCOUNT_SUFFIX}`;
              const accountPath = path.join(this.qwenDir, accountFilename);
              await fs.unlink(accountPath);
            } catch (e) {
              // Ignore file deletion errors
            }
          } else {
            this.oauth_creds = null;
            try {
              await fs.unlink(OAUTH_FILE);
            } catch (e) {
              // Ignore file deletion errors
            }
          }
        }

        throw new Error(errorMsg);
      }

      const data = JSON.parse(responseText);

      const expiry_date = Date.now() + data.expires_in * 1000;

      const newCredentials = {
        access_token: data.access_token,
        token_type: data.token_type,
        refresh_token: data.refresh_token || refresh_token,
        resource_url: data.resource_url,
        expiry_date: expiry_date,
      };

      this.oauth_creds = newCredentials;

      const dir = path.dirname(OAUTH_FILE);
      try {
        await fs.mkdir(dir, { recursive: true });
      } catch (e) {
        // Directory might already exist
      }

      await fs.writeFile(OAUTH_FILE, JSON.stringify(newCredentials, null, 2));

      return newCredentials.access_token;
    } catch (error) {
      this.refreshPromise = null; // Clear the promise on error
      throw error;
    }
  }

  async transformRequestIn(request, provider) {
    // Load all accounts for multi-account support
    await this.loadAllAccounts();
    const accountIds = this.getAccountIds();
    
    let accountId = null;
    let credentials = null;
    
    // If we have multiple accounts, select one using round-robin
    if (accountIds.length > 0) {
      const accountInfo = await this.getNextAccount();
      if (accountInfo) {
        accountId = accountInfo.accountId;
        credentials = accountInfo.credentials;
        console.log(`\x1b[36mUsing account ${accountId} (Request #${this.getRequestCount(accountId) + 1} today)\x1b[0m`);
      }
    }
    
    // If no account was selected or we have no accounts, use default credentials
    if (!credentials) {
      credentials = await this.loadCredentials();
      if (!credentials) {
        throw new Error("No Qwen credentials found. Please authenticate first.");
      }
    }
    
    // Ensure we have valid credentials for the selected account
    const accessToken = await this.getValidToken(accountId);
    
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

    let qwenEndpoint = credentials?.resource_url;
    if (!qwenEndpoint.startsWith("http")) {
      qwenEndpoint = "https://" + qwenEndpoint;
    }
    if (!qwenEndpoint.endsWith("/v1")) {
      qwenEndpoint = qwenEndpoint + "/v1";
    }
    const url = new URL(qwenEndpoint + "/chat/completions");

    // Increment request count for this account
    if (accountId) {
      await this.incrementRequestCount(accountId);
    }

    return {
      body: body,
      config: {
        url: url,
        method: "POST",
        headers: {
          Authorization: `Bearer ${accessToken}`,
          "Content-Type": "application/json",
        },
      },
    };
  }
}

module.exports = QwenCLITransformer;
