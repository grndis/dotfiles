-- if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

return {
  {
    "Kurama622/llm.nvim",
    dependencies = { "nvim-lua/plenary.nvim", "MunifTanjim/nui.nvim" },
    cmd = { "LLMSessionToggle", "LLMSelectedTextHandler", "LLMAppHandler" },
    config = function()
      local tools = require "llm.common.tools"
      require("llm").setup {
        -- [[ Github Models ]]
        url = "https://models.inference.ai.azure.com/chat/completions",
        model = "gpt-4o-mini",
        api_type = "openai",
        temperature = 0.3,
        top_p = 0.7,

        spinner = {
          text = {
            "󰧞󰧞",
            "󰧞󰧞",
            "󰧞󰧞",
            "󰧞󰧞",
          },
        },

        prefix = {
          user = { text = "  ", hl = "Title" },
          assistant = { text = "  ", hl = "Added" },
        },
        -- history_path = "/tmp/llm-history",
        save_session = true,
        max_history = 15,
        max_history_name_length = 20,

        -- stylua: ignore
        keys = {
          -- The keyboard mapping for the input window.
          ["Input:Submit"]      = { mode = "n", key = "<cr>" },
          ["Input:Cancel"]      = { mode = {"n", "i"}, key = "<C-c>" },
          ["Input:Resend"]      = { mode = {"n", "i"}, key = "<C-r>" },

          -- only works when "save_session = true"
          ["Input:HistoryNext"] = { mode = {"n", "i"}, key = "<C-j>" },
          ["Input:HistoryPrev"] = { mode = {"n", "i"}, key = "<C-k>" },

          -- The keyboard mapping for the output window in "split" style.
          ["Output:Ask"]        = { mode = "n", key = "i" },
          ["Output:Cancel"]     = { mode = "n", key = "<C-c>" },
          ["Output:Resend"]     = { mode = "n", key = "<C-r>" },

          -- The keyboard mapping for the output and input windows in "float" style.
          ["Session:Toggle"]    = { mode = "n", key = "<leader>ac" },
          ["Session:Close"]     = { mode = "n", key = {"<esc>", "Q"} },

          -- Scroll
          ["PageUp"]            = { mode = {"i","n"}, key = "<C-b>" },
          ["PageDown"]          = { mode = {"i","n"}, key = "<C-f>" },
          ["HalfPageUp"]        = { mode = {"i","n"}, key = "<C-u>" },
          ["HalfPageDown"]      = { mode = {"i","n"}, key = "<C-d>" },
          ["JumpToTop"]         = { mode = "n", key = "gg" },
          ["JumpToBottom"]      = { mode = "n", key = "G" },
        },
        display = {
          diff = {
            layout = "vertical", -- vertical|horizontal split for default provider
            opts = { "internal", "filler", "closeoff", "algorithm:patience", "followwrap", "linematch:120" },
            provider = "mini_diff", -- default|mini_diff
          },
        },
        app_handler = {
          -- Your AI tools Configuration
          -- TOOL_NAME = { ... }
          DocString = {
            prompt = [[ You are an AI programming assistant. You need to write a really good docstring that follows a best practice for the given language.

                    Your core tasks include:
                    - parameter and return types (if applicable).
                    - any errors that might be raised or returned, depending on the language.

                    You must:
                    - Place the generated docstring before the start of the code.
                    - Follow the format of examples carefully if the examples are provided.
                    - Use Markdown formatting in your answers.
                    - Include the programming language name at the start of the Markdown code blocks.]],
            handler = tools.action_handler,
            opts = {
              apply_visual_selection = true,
              enter_flexible_window = true,
              templates = {
                lua = [[- For the Lua language, you should use the LDoc style.
                      - Start all comment lines with "---".
                      ]],
              },
            },
          },
          OptimizeCode = {
            handler = tools.side_by_side_handler,
            opts = {
              left = {
                focusable = false,
              },
            },
          },
          CommitMsg = {
            handler = tools.flexi_handler,
            prompt = function()
              -- Source: https://andrewian.dev/blog/ai-git-commits
              return string.format(
                [[You are an expert at following the Conventional Commit specification. Given the git diff listed below, please generate a commit message for me:
                              1. First line: conventional commit format (type: concise description) (remember to use semantic types like feat, fix, docs, style, refactor, perf, test, chore, etc.)
                              2. Optional bullet points if more context helps:
                                - Keep the second line blank
                                - Keep them short and direct
                                - Focus on what changed
                                - Always be terse
                                - Don't overly explain
                                - Drop any fluffy or formal language

                              Return ONLY the commit message - no introduction, no explanation, no quotes around it.

                              Examples:
                              feat: add user auth system

                              - Add JWT tokens for API auth
                              - Handle token refresh for long sessions

                              fix: resolve memory leak in worker pool

                              - Clean up idle connections
                              - Add timeout for stale workers

                              Simple change example:
                              fix: typo in README.md

                              Very important: Do not respond with any of the examples. Your message must be based off the diff that is about to be provided, with a little bit of styling informed by the recent commits you're about to see.

                              Based on this format, generate appropriate commit messages. Respond with message only. DO NOT format the message in Markdown code blocks, DO NOT use backticks:

                              ```diff
                              %s
                              ```
                              ]],
                vim.fn.system "git diff --no-ext-diff --staged"
              )
            end,

            opts = {
              enter_flexible_window = true,
              apply_visual_selection = false,
              timeout = 15,
              win_opts = {
                relative = "editor",
                position = "50%",
              },
              accept = {
                mapping = {
                  mode = "n",
                  keys = "<cr>",
                },
                action = function()
                  local contents = vim.api.nvim_buf_get_lines(0, 0, -1, true)
                  vim.api.nvim_command(string.format('!git commit -m "%s"', table.concat(contents, '" -m "')))

                  -- just for lazygit
                  vim.schedule(function() vim.api.nvim_command "LazyGit" end)
                end,
              },
            },
          },
        },
      }
    end,
    keys = {
      { "<leader>ac", mode = "n", "<cmd>LLMSessionToggle<cr>", desc = "AI Chat" },
      { "<leader>ae", mode = "x", "<cmd>LLMSelectedTextHandler Explain<cr>", desc = "Explain Code" },
      { "<leader>ad", mode = "x", "<cmd>LLMAppHandler DocString<cr>", desc = "Generate DocString" },
      { "<leader>ao", mode = "x", "<cmd>LLMAppHandler OptimizeCode<cr>", desc = "Optimize Code" },
      { "<leader>ag", mode = "n", "<cmd>LLMAppHandler CommitMsg<cr>", desc = "Generate Commit Message" },
    },
  },
}
