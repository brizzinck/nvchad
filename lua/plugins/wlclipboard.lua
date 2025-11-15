return {
  "ojroques/nvim-osc52",
  config = function()
    require("osc52").setup {
      max_length = 0,
      silent = false,
      trim = true,
    }

    local function copy(lines)
      require("osc52").copy(table.concat(lines, "\n"))
    end

    vim.g.clipboard = {
      name = "osc52",
      copy = {
        ["+"] = copy,
        ["*"] = copy,
      },
      paste = {
        ["+"] = function()
          return { vim.fn.getreg '"' }
        end,
        ["*"] = function()
          return { vim.fn.getreg '"' }
        end,
      },
    }

    vim.api.nvim_create_autocmd("TextYankPost", {
      callback = function()
        require("osc52").copy_register '"'
      end,
    })
  end,
}
