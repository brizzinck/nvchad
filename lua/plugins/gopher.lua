return {
  "olexsmir/gopher.nvim",
  ft = "go",
  config = function(_, opts)
    require("gopher").setup(opts)

    local map = vim.keymap.set
    map("n", "<leader>Ge", "<cmd>GoIfErr<CR>", { desc = "Go: if err != nil" })
    map("n", "<leader>Gc", "<cmd>GoCmt<CR>", { desc = "Go: generate comment" })
    map("n", "<leader>Gi", "<cmd>GoImpl<CR>", { desc = "Go: implement interface" })
    map("n", "<leader>Gj", "<cmd>GoTagAdd json<CR>", { desc = "Go: add json tags" })
    map("n", "<leader>Gy", "<cmd>GoTagAdd yaml<CR>", { desc = "Go: add yaml tags" })
    map("n", "<leader>Gr", "<cmd>GoTagRm<CR>", { desc = "Go: remove tags" })
    map("n", "<leader>Gt", "<cmd>GoTestAdd<CR>", { desc = "Go: generate test for func" })
    map("n", "<leader>GT", "<cmd>GoTestsAll<CR>", { desc = "Go: generate tests for file" })
    map("n", "<leader>Gm", "<cmd>GoMod tidy<CR>", { desc = "Go: mod tidy" })
    map("n", "<leader>Gg", "<cmd>GoGenerate<CR>", { desc = "Go: go generate" })
    map("n", "<leader>Gd", "<cmd>GoInstallDeps<CR>", { desc = "Go: install gopher deps" })

    map("n", "<leader>Ga", function()
      local path = vim.fn.expand "%:p"
      if path == "" then
        return
      end
      local alt
      if path:match "_test%.go$" then
        alt = path:gsub("_test%.go$", ".go")
      elseif path:match "%.go$" then
        alt = path:gsub("%.go$", "_test.go")
      else
        vim.notify("Not a Go file", vim.log.levels.WARN)
        return
      end
      vim.cmd("edit " .. vim.fn.fnameescape(alt))
    end, { desc = "Go: toggle test/impl file" })
  end,
  build = function()
    vim.cmd [[silent! GoInstallDeps]]
  end,
}
