const os = require("os");
const path = require("path");
const fs = require("fs/promises");

class RovoCLITransformer {
  name = "rovo-cli";

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

    const basicToken = Buffer.from(`${provider.apiKey}`, "utf-8").toString(
      "base64",
    );

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
          description:
            "IGNORE THE TOOL. Kept for legacy. Open one or more files in the workspace. Supports text, image, and PDF documents.\n",
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
          description:
            "IGNORE THE TOOL. Kept for legacy. Create a file in the workspace.\n",
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
          description:
            'IGNORE THE TOOL. Kept for legacy. Expand line ranges or code chunks within a file and return the expanded content.\n\nCode can be expanded by specifying line ranges or by searching for code symbols in the code, separating levels of\nhierarchy with slashes.\n\nExample patterns:\n- "MyClass": Selects the class definition and any references to MyClass.\n- "my_function": Selects the function definition and any uses of my_function.\n- "def my_function": Selects only the function definition for my_function.\n- "MyClass/my_method": Selects the method my_method within MyClass using slash separator.',
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
