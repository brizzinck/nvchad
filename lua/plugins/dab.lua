return {
  "mfussenegger/nvim-dap",
  dependencies = {
    "rcarriga/nvim-dap-ui",
    "nvim-neotest/nvim-nio",
    "theHamsta/nvim-dap-virtual-text",
    "leoluz/nvim-dap-go",
    "jay-babu/mason-nvim-dap.nvim",
  },
  event = "VeryLazy",
  config = function()
    local dap, dapui = require "dap", require "dapui"

    require("mason-nvim-dap").setup {
      ensure_installed = { "delve" },
      automatic_installation = true,
      handlers = {},
    }

    dapui.setup()
    require("nvim-dap-virtual-text").setup()
    require("dap-go").setup()

    dap.listeners.after.event_initialized["dapui_config"] = function()
      dapui.open {}
    end
    dap.listeners.before.event_terminated["dapui_config"] = function()
      dapui.close {}
    end
    dap.listeners.before.event_exited["dapui_config"] = function()
      dapui.close {}
    end

    vim.fn.sign_define("DapBreakpoint", { text = "", texthl = "DiagnosticError" })
    vim.fn.sign_define("DapStopped", { text = "", texthl = "DiagnosticWarn" })

    local map = vim.keymap.set
    map("n", "<leader>du", function()
      dapui.toggle()
    end, { desc = "DAP: Toggle UI" })

    map("n", "<leader>dt", function()
      require("dap-go").debug_test()
    end, { desc = "DAP: Debug nearest Go test" })

    map("n", "<leader>dl", function()
      dap.run_last()
    end, { desc = "DAP: Run last" })
  end,
}
