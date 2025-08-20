const os = require("os");
const path = require("path");
const fs = require("fs/promises");

const QWEN_DIR = path.join(os.homedir(), ".qwen");
const OAUTH_FILE = path.join(QWEN_DIR, "oauth_creds.json");
const QWEN_MULTI_ACCOUNT_PREFIX = "oauth_creds_";
const QWEN_MULTI_ACCOUNT_SUFFIX = ".json";

class QwenCodeTransformer {
  name = "qwen-code";
  
  constructor() {
    this.accounts = new Map();
    this.currentAccountIndex = 0;
    this.oauth_creds = null;
  }

  async transformRequestIn(request, provider) {
    // Load all accounts if not already loaded
    if (this.accounts.size === 0) {
      await this.loadAllAccounts();
    }
    
    // Get current account
    const account = await this.getCurrentAccount();
    if (!account) {
      throw new Error("No valid Qwen accounts available. Please authenticate with Qwen CLI first.");
    }
    
    const { accountId, credentials } = account;
    
    // Check if token needs refresh
    if (credentials.expiry_date < +new Date()) {
      const refreshedCredentials = await this.refreshToken(credentials.refresh_token, accountId);
      if (refreshedCredentials) {
        // Update current credentials
        this.accounts.set(accountId, refreshedCredentials);
        this.oauth_creds = refreshedCredentials;
      } else {
        // Token refresh failed, rotate to next account
        this.rotateAccount();
        return this.transformRequestIn(request, provider); // Retry with next account
      }
    } else {
      this.oauth_creds = credentials;
    }
    
    if (request.stream) {
      request.stream_options = {
        include_usage: true,
      };
    }
    return {
      body: request,
      config: {
        headers: {
          Authorization: `Bearer ${this.oauth_creds.access_token}`,
          "User-Agent": "QwenCode/v22.12.0 (darwin; arm64)",
        },
      },
    };
  }

  async transformResponseOut(response, request, provider) {
    // Check if response indicates auth error
    if (response.status === 401 || response.status === 403) {
      // Rotate to next account and retry
      this.rotateAccount();
    }
    return response;
  }

  refreshToken(refresh_token, accountId = null) {
    const urlencoded = new URLSearchParams();
    urlencoded.append("client_id", "f0304373b74a44d2b584a3fb70ca9e56");
    urlencoded.append("refresh_token", refresh_token);
    urlencoded.append("grant_type", "refresh_token");
    return fetch("https://chat.qwen.ai/api/v1/oauth2/token", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: urlencoded,
    })
      .then((response) => response.json())
      .then(async (data) => {
        if (data.error) {
          // Refresh token failed
          console.error(`Token refresh failed for account ${accountId || 'default'}:`, data.error);
          return null;
        }
        
        const refreshedCredentials = {
          access_token: data.access_token,
          refresh_token: data.refresh_token || refresh_token,
          token_type: data.token_type,
          resource_url: data.resource_url || (this.oauth_creds ? this.oauth_creds.resource_url : undefined),
          expiry_date: new Date().getTime() + data.expires_in * 1000 - 1000 * 60,
        };
        
        // Save refreshed credentials
        if (accountId) {
          const accountFilename = `${QWEN_MULTI_ACCOUNT_PREFIX}${accountId}${QWEN_MULTI_ACCOUNT_SUFFIX}`;
          const accountPath = path.join(QWEN_DIR, accountFilename);
          await fs.writeFile(accountPath, JSON.stringify(refreshedCredentials, null, 2));
        } else {
          await fs.writeFile(OAUTH_FILE, JSON.stringify(refreshedCredentials, null, 2));
        }
        
        return refreshedCredentials;
      })
      .catch((error) => {
        console.error(`Token refresh error for account ${accountId || 'default'}:`, error.message);
        return null;
      });
  }

  /**
   * Load all multi-account credentials
   */
  async loadAllAccounts() {
    try {
      // Clear existing accounts
      this.accounts.clear();
      
      // Read directory to find all credential files
      const files = await fs.readdir(QWEN_DIR);
      
      // Filter for multi-account credential files
      const accountFiles = files.filter(file => 
        file.startsWith(QWEN_MULTI_ACCOUNT_PREFIX) && 
        file.endsWith(QWEN_MULTI_ACCOUNT_SUFFIX) &&
        file !== "oauth_creds.json"
      );
      
      // Load each account
      for (const file of accountFiles) {
        try {
          const accountPath = path.join(QWEN_DIR, file);
          const credentialsData = await fs.readFile(accountPath, "utf8");
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
        const defaultCredentialsData = await fs.readFile(OAUTH_FILE, "utf8");
        const defaultCredentials = JSON.parse(defaultCredentialsData);
        this.accounts.set("default", defaultCredentials);
      } catch (error) {
        console.warn("Failed to load default account:", error.message);
      }
    } catch (error) {
      console.warn("Failed to load multi-account credentials:", error.message);
    }
  }

  /**
   * Get account IDs
   */
  getAccountIds() {
    return Array.from(this.accounts.keys());
  }

  /**
   * Get credentials for a specific account
   */
  getAccountCredentials(accountId) {
    return this.accounts.get(accountId) || null;
  }

  /**
   * Get current account using round-robin selection
   */
  async getCurrentAccount() {
    const accountIds = this.getAccountIds();
    
    if (accountIds.length === 0) {
      return null;
    }
    
    // Use round-robin selection
    const accountId = accountIds[this.currentAccountIndex];
    const credentials = this.getAccountCredentials(accountId);
    
    return { accountId, credentials };
  }

  /**
   * Rotate to next account
   */
  rotateAccount() {
    const accountIds = this.getAccountIds();
    
    if (accountIds.length > 1) {
      this.currentAccountIndex = (this.currentAccountIndex + 1) % accountIds.length;
    }
  }

  /**
   * Check if an account has valid credentials
   */
  isAccountValid(accountId) {
    const credentials = this.getAccountCredentials(accountId);
    if (!credentials || !credentials.expiry_date) {
      return false;
    }
    return Date.now() < credentials.expiry_date - 30000; // 30 second buffer
  }
}

module.exports = QwenCodeTransformer;
