const os = require("os");
const path = require("path");
const fs = require("fs/promises");

const OAUTH_FILE = path.join(os.homedir(), ".gemini", "oauth_creds.json");

class GeminiCLITransformer {
  name = "gemini-cli";

  constructor(options) {
    this.options = options;
    try {
      this.oauth_creds = require(OAUTH_FILE);
    } catch {}
  }

  async transformRequestIn(request, provider) {
    if (this.oauth_creds && this.oauth_creds.expiry_date < +new Date()) {
      await this.refreshToken(this.oauth_creds.refresh_token);
    }
    return {
      body: {
        request: {
          contents: request.messages.map((message) => {
            let role;
            if (message.role === "assistant") {
              role = "model";
            } else if (["user", "system", "tool"].includes(message.role)) {
              role = "user";
            } else {
              role = "user"; // Default to user if role is not recognized
            }
            const parts = [];
            if (typeof message.content === "string") {
              parts.push({
                text: message.content,
              });
            } else if (Array.isArray(message.content)) {
              parts.push(
                ...message.content.map((content) => {
                  if (content.type === "text") {
                    return {
                      text: content.text || "",
                    };
                  }
                }),
              );
            }

            if (Array.isArray(message.tool_calls)) {
              parts.push(
                ...message.tool_calls.map((toolCall) => {
                  return {
                    functionCall: {
                      id:
                        toolCall.id ||
                        `tool_${Math.random().toString(36).substring(2, 15)}`,
                      name: toolCall.function.name,
                      args: JSON.parse(toolCall.function.arguments || "{}"),
                    },
                  };
                }),
              );
            }
            return {
              role,
              parts,
            };
          }),
          tools: request.tools?.length
            ? [
                {
                  functionDeclarations:
                    request.tools?.map((tool) => {
                      delete tool.function.parameters?.$schema;
                      delete tool.function.parameters?.additionalProperties;
                      if (tool.function.parameters?.properties) {
                        Object.keys(
                          tool.function.parameters.properties,
                        ).forEach((key) => {
                          delete tool.function.parameters.properties[key]
                            .$schema;
                          delete tool.function.parameters.properties[key]
                            .additionalProperties;
                          if (
                            tool.function.parameters.properties[key].items &&
                            typeof tool.function.parameters.properties[key]
                              .items === "object"
                          ) {
                            delete tool.function.parameters.properties[key]
                              .items.$schema;
                            delete tool.function.parameters.properties[key]
                              .items.additionalProperties;
                          }

                          if (
                            tool.function.parameters.properties[key].type ===
                            "string"
                          ) {
                            if (
                              !["enum", "date-time"].includes(
                                tool.function.parameters.properties[key].format,
                              )
                            ) {
                              delete tool.function.parameters.properties[key]
                                .format;
                            }
                          }
                        });
                      }
                      return {
                        name: tool.function.name,
                        description: tool.function.description,
                        parameters: tool.function.parameters,
                      };
                    }) || [],
                },
              ]
            : undefined,
        },
        model: request.model,
        project: this.options?.project,
      },
      config: {
        url: new URL(
          `https://cloudcode-pa.googleapis.com/v1internal:${
            request.stream ? "streamGenerateContent?alt=sse" : "generateContent"
          }`,
        ),
        headers: {
          Authorization: `Bearer ${this.oauth_creds.access_token}`,
        },
      },
    };
  }

  async transformResponseOut(response) {
    if (response.headers.get("Content-Type")?.includes("application/json")) {
      let jsonResponse = await response.json();
      jsonResponse = jsonResponse.response;
      const tool_calls = jsonResponse.candidates[0].content.parts
        .filter((part) => part.functionCall)
        .map((part) => ({
          id:
            part.functionCall?.id ||
            `tool_${Math.random().toString(36).substring(2, 15)}`,
          type: "function",
          function: {
            name: part.functionCall?.name,
            arguments: JSON.stringify(part.functionCall?.args || {}),
          },
        }));
      const res = {
        id: jsonResponse.responseId,
        choices: [
          {
            finish_reason:
              jsonResponse.candidates[0].finishReason?.toLowerCase() || null,
            index: 0,
            message: {
              content: jsonResponse.candidates[0].content.parts
                .filter((part) => part.text)
                .map((part) => part.text)
                .join("\n"),
              role: "assistant",
              tool_calls: tool_calls.length > 0 ? tool_calls : undefined,
            },
          },
        ],
        created: parseInt(new Date().getTime() / 1000 + "", 10),
        model: jsonResponse.modelVersion,
        object: "chat.completion",
        usage: {
          completion_tokens: jsonResponse.usageMetadata.candidatesTokenCount,
          prompt_tokens: jsonResponse.usageMetadata.promptTokenCount,
          total_tokens: jsonResponse.usageMetadata.totalTokenCount,
        },
      };
      return new Response(JSON.stringify(res), {
        status: response.status,
        statusText: response.statusText,
        headers: response.headers,
      });
    } else if (response.headers.get("Content-Type")?.includes("stream")) {
      if (!response.body) {
        return response;
      }

      const decoder = new TextDecoder();
      const encoder = new TextEncoder();
      const stream = new ReadableStream({
        async start(controller) {
          const reader = response.body.getReader();
          try {
            while (true) {
              const { done, value } = await reader.read();
              if (done) break;

              let chunk = decoder.decode(value, { stream: true });
              if (chunk.startsWith("data: ")) {
                chunk = chunk.slice(6).trim();
              } else {
                break;
              }
              chunk = JSON.parse(chunk);
              chunk = chunk.response;
              const tool_calls = chunk.candidates[0].content.parts
                .filter((part) => part.functionCall)
                .map((part) => ({
                  id:
                    part.functionCall?.id ||
                    `tool_${Math.random().toString(36).substring(2, 15)}`,
                  type: "function",
                  function: {
                    name: part.functionCall?.name,
                    arguments: JSON.stringify(part.functionCall?.args || {}),
                  },
                }));
              const res = {
                choices: [
                  {
                    delta: {
                      role: "assistant",
                      content: chunk.candidates[0].content.parts
                        .filter((part) => part.text)
                        .map((part) => part.text)
                        .join("\n"),
                      tool_calls:
                        tool_calls.length > 0 ? tool_calls : undefined,
                    },
                    finish_reason:
                      chunk.candidates[0].finishReason?.toLowerCase() || null,
                    index:
                      chunk.candidates[0].index || tool_calls.length > 0
                        ? 1
                        : 0,
                    logprobs: null,
                  },
                ],
                created: parseInt(new Date().getTime() / 1000 + "", 10),
                id: chunk.responseId || "",
                model: chunk.modelVersion || "",
                object: "chat.completion.chunk",
                system_fingerprint: "fp_a49d71b8a1",
              };
              controller.enqueue(
                encoder.encode(`data: ${JSON.stringify(res)}\n\n`),
              );
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
    }
    return response;
  }

  refreshToken(refresh_token) {
    return fetch("https://oauth2.googleapis.com/token", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        client_id:
          "681255809395-oo8ft2oprdrnp9e3aqf6av3hmdib135j.apps.googleusercontent.com",
        client_secret: "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",
        refresh_token: refresh_token,
        grant_type: "refresh_token",
      }),
    })
      .then((response) => response.json())
      .then(async (data) => {
        data.expiry_date =
          new Date().getTime() + data.expires_in * 1000 - 1000 * 60;
        data.refresh_token = refresh_token;
        delete data.expires_in;
        this.oauth_creds = data;
        await fs.writeFile(OAUTH_FILE, JSON.stringify(data, null, 2));
      });
  }
}

module.exports = GeminiCLITransformer;
