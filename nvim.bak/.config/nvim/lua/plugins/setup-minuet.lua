if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

return {
  {
    "milanglacier/minuet-ai.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
    },
    opts = {
      provider = "gemini",
      provider_options = {
        gemini = {
          model = "gemini-2.0-flash-exp",
          stream = true,
          system = {
            prompt = function()
              local ft = vim.bo.ft
              if ft == "lua" then
                return [[You are an expert Lua programmer. Provide concise, idiomatic Lua code completions. Focus on:
- Modern Lua practices and patterns
- Performance optimizations
- Clear type annotations when helpful
- Proper error handling]]
              elseif ft == "python" then
                return [[You are an expert Python programmer. Provide concise, Pythonic code completions. Focus on:
- PEP 8 compliance
- Type hints for clarity
- Modern Python features (3.8+)
- Efficient algorithms and data structures]]
              elseif ft == "typescript" or ft == "javascript" then
                return [[You are an expert TypeScript/JavaScript developer. Provide concise, modern code completions. Focus on:
- TypeScript type safety
- ES6+ features
- Functional programming patterns
- React/Node.js best practices when applicable]]
              else
                return [[You are an expert programmer. Provide concise, idiomatic code completions for the current language. Focus on:
- Language-specific best practices
- Performance considerations
- Clear and maintainable code
- Proper error handling]]
              end
            end,
          },
          optional = {
            generationConfig = {
              maxOutputTokens = 512,
              temperature = 0.2,
              topP = 0.95,
              topK = 40,
            },
          },
        },
      },
    },
  },
}
