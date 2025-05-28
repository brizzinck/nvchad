return {
  {
    "tpope/vim-dadbod",
    cmd = { "DB", "DBUI", "DBUIToggle", "DBUIAddConnection" },
  },

  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "leoluz/nvim-dap-go",
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
      "jay-babu/mason-nvim-dap.nvim",
    },
    config = function()
      require("mason").setup()
      require("mason-nvim-dap").setup {
        ensure_installed = { "delve", "codelldb" },
        automatic_setup = true,
      }

      local dap = require "dap"
      local dapui = require "dapui"

      dap.adapters.codelldb = {
        type = "server",
        port = "${port}",
        executable = {
          command = vim.fn.stdpath "data" .. "/mason/bin/codelldb",
          args = { "--port", "${port}" },
        },
      }

      dap.configurations.rust = {
        {
          name = "Launch Rust program",
          type = "codelldb",
          request = "launch",
          program = function()
            local cwd = vim.fn.getcwd()
            local exe = cwd .. "/target/debug/" .. vim.fn.fnamemodify(cwd, ":t")
            return vim.fn.input("Path to executable: ", exe, "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntry = false,
          args = {},
          runInTerminal = false,
        },
      }

      dapui.setup()
      require("dap-go").setup()
      require("nvim-dap-virtual-text").setup {}

      dap.listeners.before.attach.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function()
        dapui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function()
        dapui.close()
      end
    end,
  },

  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    cmd = { "DBUI", "DBUIToggle" },
    config = function()
      vim.g.db_ui_save_location = "~/.config/nvim/db_connections"
    end,
  },

  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = { "kristijanhusak/vim-dadbod-ui", "tpope/vim-dadbod", "hrsh7th/nvim-cmp" },
    config = function()
      local cmp = require "cmp"
      cmp.setup {
        sources = {
          { name = "vim-dadbod-completion" },
        },
      }
    end,
    ft = { "sql" },
  },
}
