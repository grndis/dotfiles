return {
  {
    "antosha417/nvim-lsp-file-operations",
    -- lazy will handle loading nvim-tree and neo-tree appropriately based on the module load and our `init` function
    lazy = true,
    -- lazily load plugin after a tree plugin is loaded
    init = function(plugin) require("astrocore").on_load({ "neo-tree.nvim", "nvim-tree.lua" }, plugin.name) end,
    dependencies = {
      "AstroNvim/astrolsp",
      opts = function(_, opts)
        local operations = vim.tbl_get(require("astrocore").plugin_opts "nvim-lsp-file-operations", "operations") or {}
        local fileOperations = {}
        for _, operation in ipairs { "willRename", "didRename", "willCreate", "didCreate", "willDelete", "didDelete" } do
          fileOperations[operation] = vim.F.if_nil(vim.tbl_get(operations, operation .. "Files"), true)
        end
        if not opts.config then opts.config = {} end
        if not opts.config["*"] then opts.config["*"] = {} end
        opts.config["*"].capabilities = vim.tbl_deep_extend(
          "force",
          opts.config["*"].capabilities or {},
          { workspace = { fileOperations = fileOperations } }
        )
      end,
    },
    main = "lsp-file-operations", -- set the main module name where the `setup` function is
    opts = {},
    specs = {
      { "AstroNvim/astrolsp", opts = { file_operations = false } },
    },
  },
  {
    "AstroNvim/astrocore",
    optional = true,
    ---@type AstroCoreOpts
    opts = {
      treesitter = { ensure_installed = { "javascript", "typescript", "tsx", "jsdoc" } },
    },
  },
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@type AstroLSPOpts
    opts = {
      mappings = {
        n = {
          gs = {
            function() require("vtsls").commands.goto_source_definition() end,
            desc = "Goto Source Definition (vtsls)",
            cond = function(client) return client.name == "vtsls" end,
          },
        },
      },
      ---@diagnostic disable: missing-fields
      config = {
        vtsls = {
          settings = {
            typescript = {
              updateImportsOnFileMove = { enabled = "always" },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = "all" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = true },
              },
            },
            javascript = {
              updateImportsOnFileMove = { enabled = "always" },
              inlayHints = {
                enumMemberValues = { enabled = true },
                functionLikeReturnTypes = { enabled = true },
                parameterNames = { enabled = "literals" },
                parameterTypes = { enabled = true },
                propertyDeclarationTypes = { enabled = true },
                variableTypes = { enabled = true },
              },
            },
            vtsls = {
              enableMoveToFileCodeAction = true,
            },
          },
        },
      },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed or {}, { "vtsls" })
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed or {}, { "js" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed or {}, { "vtsls", "js-debug-adapter" })
    end,
  },
  {
    "vuki656/package-info.nvim",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {},
    event = "BufRead package.json",
  },
  {
    "yioneko/nvim-vtsls",
    lazy = true,
    dependencies = {
      "AstroNvim/astrocore",
      opts = {
        autocmds = {
          nvim_vtsls = {
            {
              event = "LspAttach",
              desc = "Load nvim-vtsls with vtsls",
              callback = function(args)
                if assert(vim.lsp.get_client_by_id(args.data.client_id)).name == "vtsls" then
                  require("vtsls")._on_attach(args.data.client_id, args.buf)
                  vim.api.nvim_del_augroup_by_name "nvim_vtsls"
                end
              end,
            },
          },
        },
      },
    },
    config = function(_, opts) require("vtsls").config(opts) end,
  },
  {
    "dmmulroy/tsc.nvim",
    cmd = "TSC",
    opts = {},
  },
  {
    "nvim-mini/mini.icons",
    optional = true,
    opts = function(_, opts)
      if not opts.file then opts.file = {} end
      opts.file[".nvmrc"] = { glyph = "", hl = "MiniIconsGreen" }
      opts.file[".node-version"] = { glyph = "", hl = "MiniIconsGreen" }
      opts.file["package.json"] = { glyph = "", hl = "MiniIconsGreen" }
      opts.file["tsconfig.json"] = { glyph = "", hl = "MiniIconsAzure" }
      opts.file["tsconfig.build.json"] = { glyph = "", hl = "MiniIconsAzure" }
      opts.file["yarn.lock"] = { glyph = "", hl = "MiniIconsBlue" }
    end,
  },
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { { "nvim-neotest/neotest-jest", config = function() end } },
    opts = function(_, opts)
      if not opts.adapters then opts.adapters = {} end
      table.insert(opts.adapters, require "neotest-jest"(require("astrocore").plugin_opts "neotest-jest"))
    end,
  },
  {
    "AstroNvim/astrolsp",
    optional = true,
    ---@param opts AstroLSPOpts
    opts = function(_, opts)
      local astrocore = require "astrocore"
      local vtsls_ft = astrocore.list_insert_unique(vim.tbl_get(opts, "config", "vtsls", "filetypes") or {
        "javascript",
        "javascriptreact",
        "javascript.jsx",
        "typescript",
        "typescriptreact",
        "typescript.tsx",
      }, { "vue" })
      return astrocore.extend_tbl(opts, {
        ---@diagnostic disable: missing-fields
        config = {
          volar = {
            on_init = function(client)
              client.handlers["tsserver/request"] = function(_, result, context)
                local clients = vim.lsp.get_clients { bufnr = context.bufnr, name = "vtsls" }
                if #clients == 0 then
                  vim.notify(
                    "Could not found `vtsls` lsp client, vue_lsp would not work without it.",
                    vim.log.levels.ERROR
                  )
                  return
                end
                local ts_client = clients[1]

                local param = unpack(result)
                local id, command, payload = unpack(param)
                ts_client:exec_cmd({
                  title = "vue_request_forward", -- You can give title anything as it's used to represent a command in the UI, `:h Client:exec_cmd`
                  command = "typescript.tsserverRequest",
                  arguments = {
                    command,
                    payload,
                  },
                }, { bufnr = context.bufnr }, function(_, r)
                  local response_data = { { id, r.body } }
                  client:notify("tsserver/response", response_data)
                end)
              end
            end,
          },
          vtsls = {
            filetypes = vtsls_ft,
            settings = {
              vtsls = {
                tsserver = {
                  globalPlugins = {},
                },
              },
            },
            before_init = function(_, config)
              local registry_ok, registry = pcall(require, "mason-registry")
              if not registry_ok then return end

              if registry.is_installed "vue-language-server" then
                local vue_plugin_config = {
                  name = "@vue/typescript-plugin",
                  location = vim.fn.expand "$MASON/packages/vue-language-server/node_modules/@vue/language-server",
                  languages = { "vue" },
                  configNamespace = "typescript",
                  enableForWorkspaceTypeScriptVersions = true,
                }

                astrocore.list_insert_unique(config.settings.vtsls.tsserver.globalPlugins, { vue_plugin_config })
              end
            end,
          },
        },
      })
    end,
  },
  {
    "AstroNvim/astrocore",
    optional = true,
    ---@type AstroCoreOpts
    opts = {
      treesitter = { ensure_installed = { "vue" } },
    },
  },
  {
    "mason-org/mason-lspconfig.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "volar" })
    end,
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, { "js" })
    end,
  },
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed, { "vue-language-server", "js-debug-adapter" })
    end,
  },
}
