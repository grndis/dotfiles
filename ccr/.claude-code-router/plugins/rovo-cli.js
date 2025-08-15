const os = require("os");
const path = require("path");
const fs = require("fs/promises");

// File System Configuration
const ROVO_DIR = '.rovo';
const ROVO_CREDENTIAL_FILENAME = 'cred.json';
const ROVO_FILE = path.join(os.homedir(), ROVO_DIR, ROVO_CREDENTIAL_FILENAME);

class RovoCLITransformer {
  name = "rovo-cli";

  constructor(options) {
    this.options = options;
    this.rovoDir = path.join(os.homedir(), ROVO_DIR);
    this.credentialsPath = ROVO_FILE;
    this.accounts = [];
    this.currentAccountIndex = 0; // For round-robin account selection
  }

  /**
   * Load all Rovo accounts from credentials file
   * @returns {Promise<Array>} Array of account credentials
   */
  async loadAllAccounts() {
    try {
      // Clear existing accounts
      this.accounts = [];
      
      // Read credentials file
      const credentialsData = await fs.readFile(this.credentialsPath, 'utf8');
      const credentials = JSON.parse(credentialsData);
      
      // Ensure it's an array
      let accountsArray = [];
      if (Array.isArray(credentials)) {
        accountsArray = credentials;
      } else if (credentials && typeof credentials === 'object') {
        // If it's a single object, convert to array
        accountsArray = [credentials];
      }
      
      // Validate accounts format
      const validAccounts = accountsArray.filter(account => 
        account && 
        typeof account === 'object' && 
        account.email && 
        typeof account.email === 'string' && 
        account.api_token && 
        typeof account.api_token === 'string'
      );
      
      if (validAccounts.length !== accountsArray.length) {
        console.warn(`Warning: Found ${accountsArray.length - validAccounts.length} invalid account entries in credentials file`);
      }
      
      this.accounts = validAccounts;
      
      return this.accounts;
    } catch (error) {
      console.warn('Failed to load Rovo credentials:', error.message);
      return this.accounts;
    }
  }

  /**
   * Get the next available account for rotation
   * @returns {Object|null} Account credentials or null if no accounts available
   */
  async getNextAccount() {
    // Load all accounts if not already loaded
    if (this.accounts.length === 0) {
      await this.loadAllAccounts();
    }
    
    if (this.accounts.length === 0) {
      return null;
    }
    
    // Use round-robin selection
    const account = this.accounts[this.currentAccountIndex];
    
    // Update index for next call
    this.currentAccountIndex = (this.currentAccountIndex + 1) % this.accounts.length;
    
    return account;
  }

  async transformRequestIn(request, provider) {
    const body =
      typeof request === "string" ? JSON.parse(request) : { ...request };

    if (Object.prototype.hasOwnProperty.call(body, "max_tokens")) {
      if (
        !Object.prototype.hasOwnProperty.call(body, "max_completion_tokens")
      ) {
        body.max_completion_tokens = body.max_tokens;
      }
      delete body.max_tokens;
    }
    if (body.params && typeof body.params === "object") {
      if (Object.prototype.hasOwnProperty.call(body.params, "max_tokens")) {
        if (
          !Object.prototype.hasOwnProperty.call(
            body.params,
            "max_completion_tokens",
          )
        ) {
          body.params.max_completion_tokens = body.params.max_tokens;
        }
        delete body.params.max_tokens;
      }
    }

    const toolsToAdd = await this.getDefaultRovoTools();

    const existingTools = Array.isArray(body.tools) ? body.tools : [];
    const byName = new Map();
    for (const t of existingTools) {
      const key = t?.function?.name || JSON.stringify(t);
      byName.set(key, t);
    }
    for (const t of toolsToAdd) {
      const key = t?.function?.name || JSON.stringify(t);
      if (!byName.has(key)) byName.set(key, t);
    }
    body.tools = Array.from(byName.values());

    // Get next account for round-robin selection
    const account = await this.getNextAccount();
    if (!account) {
      throw new Error("No Rovo credentials found. Please add credentials to ~/.rovo/cred.json");
    }

    const email = account.email;
    const api_token = account.api_token;
    const basicToken = Buffer.from(`${email}:${api_token}`, "utf-8").toString(
      "base64",
    );

    // Add debug information
    console.log(`\x1b[36mUsing Rovo account ${email}\x1b[0m`);
    console.log(`\x1b[2mAccount index: ${this.currentAccountIndex}\x1b[0m`);

    return {
      body,
      config: {
        headers: {
          Authorization: `Basic ${basicToken}`,
        },
      },
    };
  }

  getDefaultRovoTools() {
    return [
      {
        type: "function",
        function: {
          name: "open_files_legacy",
          description: "IGNORE THE TOOL. Kept for legacy. Open one or more files in the workspace. Supports text, image, and PDF documents.",
          parameters: {
            type: "object",
            properties: {
              file_paths: {
                type: "array",
                items: { type: "string" },
                description: "A list of file paths to open.",
              },
            },
            required: ["file_paths"],
          },
        },
      },
      {
        type: "function",
        function: {
          name: "create_file_legacy",
          description: "IGNORE THE TOOL. Kept for legacy. Create a file in the workspace.",
          parameters: {
            type: "object",
            properties: {
              file_path: { type: "string" },
            },
            required: ["file_path"],
          },
        },
      },
      {
        type: "function",
        function: {
          name: "expand_code_chunks_legacy",
          description: "IGNORE THE TOOL. Kept for legacy. Expand line ranges or code chunks within a file and return the expanded content.",
          parameters: {
            type: "object",
            properties: {
              file_path: { type: "string" },
            },
            required: ["file_path"],
          },
        },
      },
    ];
  }
}

module.exports = RovoCLITransformer;