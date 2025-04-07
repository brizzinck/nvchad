return {
  "simrat39/rust-tools.nvim",
  ft = { "rust" },
  dependencies = { "neovim/nvim-lspconfig" },
  config = function()
    local capabilities = require("cmp_nvim_lsp").default_capabilities()

    require("rust-tools").setup {
      tools = {
        inlay_hints = {
          auto = true,
          only_current_line = false,
          show_parameter_hints = true,
          parameter_hints_prefix = "<- ",
          other_hints_prefix = "=> ",
        },
      },
      server = {
        capabilities = capabilities,
        settings = {
          ["rust-analyzer"] = {
            procMacro = { enable = true },
            cargo = {
              buildScripts = { enable = true },
            },
            checkOnSave = {
              command = "clippy",
            },
            diagnostics = {
              enable = true,
              disabled = {},
            },
            logLevel = "off",
          },
        },
        on_attach = function(client, bufnr)
          local opts = { buffer = bufnr }

          vim.keymap.set("n", "<leader>ra", vim.lsp.buf.code_action, opts)
          vim.keymap.set("v", "<leader>fe", vim.lsp.buf.code_action, opts)
          vim.keymap.set("n", "<leader>rr", vim.lsp.buf.rename, opts)
          vim.keymap.set("n", "<leader>rf", function()
            vim.lsp.buf.format { async = true }
          end, opts)
          vim.keymap.set("n", "<leader>rh", vim.lsp.buf.hover, opts)
          vim.keymap.set("n", "<leader>rs", vim.lsp.buf.signature_help, opts)
          vim.keymap.set("n", "<leader>rd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "<leader>ri", vim.lsp.buf.implementation, opts)
          vim.keymap.set("n", "<leader>rR", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "<leader>rc", vim.lsp.codelens.run, opts)

          vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)

          if client.server_capabilities.documentFormattingProvider then
            vim.api.nvim_create_autocmd("BufWritePre", {
              buffer = bufnr,
              callback = function()
                vim.lsp.buf.format { async = false }
              end,
            })
          end
        end,
      },
    }
  end,
}
