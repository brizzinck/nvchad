local configs = require "nvchad.configs.lspconfig"
local lsp = vim.lsp

local on_attach_default = configs.on_attach
local on_init = configs.on_init
local capabilities_default = configs.capabilities

local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities_default)
cmp_capabilities.offsetEncoding = { "utf-16" }

local function on_attach_extended(client, bufnr)
  if on_attach_default then
    on_attach_default(client, bufnr)
  end

  if client.server_capabilities.textDocumentSync then
    require("vim.lsp._changetracking").init(client, bufnr)
  end

  local function buf_map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  buf_map("n", "K", vim.lsp.buf.hover, "Hover Documentation")
  buf_map("n", "gd", vim.lsp.buf.definition, "Go to Definition")
  buf_map("n", "gD", vim.lsp.buf.declaration, "Go to Declaration")
  buf_map("n", "gi", vim.lsp.buf.implementation, "Go to Implementation")
  buf_map("n", "gr", vim.lsp.buf.references, "Find References")
  buf_map("n", "<leader>rn", vim.lsp.buf.rename, "Rename Symbol")
  buf_map("n", "<leader>ca", vim.lsp.buf.code_action, "Code Action")

  buf_map("n", "<leader>ra", vim.lsp.buf.code_action, "Code Action (Alt)")
  buf_map("n", "<leader>rr", vim.lsp.buf.rename, "Rename Symbol (Alt)")
  buf_map("n", "<leader>rf", function()
    vim.lsp.buf.format { async = true }
  end, "Format Document")
  buf_map("n", "<leader>rh", vim.lsp.buf.hover, "Hover")
  buf_map("n", "<leader>rs", vim.lsp.buf.signature_help, "Signature Help")
  buf_map("n", "<leader>rd", vim.lsp.buf.definition, "Definition")
  buf_map("n", "<leader>ri", vim.lsp.buf.implementation, "Implementation")
  buf_map("n", "<leader>rR", vim.lsp.buf.references, "References")
  buf_map("n", "<leader>rc", vim.lsp.codelens.run, "Run CodeLens")
  buf_map("n", "<leader>cl", vim.lsp.codelens.run, "Run CodeLens (Alt)")
  buf_map("n", "<leader>f", function()
    vim.lsp.buf.format { async = true }
  end, "Format Document (Alt)")

  buf_map("n", "gt", vim.lsp.buf.type_definition, "Go to Type Definition")
end

lsp.enable "gopls"
lsp.config("gopls", {
  cmd = { "gopls" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
  settings = {
    gopls = {
      gofumpt = true,
      completeUnimported = true,
      usePlaceholders = true,
      hints = {
        assignVariableTypes = true,
        compositeLiteralFields = true,
        compositeLiteralTypes = true,
        constantValues = true,
        functionTypeParameters = true,
        parameterNames = true,
        rangeVariableTypes = true,
      },
      analyses = {
        unusedparams = true,
      },
      buildFlags = { "-tags=integration_database_test" },
    },
  },
})

lsp.enable "dotnet"
lsp.config("dotnet", {
  cmd = { "dotnet", vim.fn.stdpath "data" .. "/mason/packages/omnisharp/libexec/OmniSharp.dll" },
  filetypes = { "cs", "vb" },
  init_options = {},
  settings = {
    {
      FormattingOptions = {
        EnableEditorConfigSupport = true,
        OrganizeImports = true,
      },
      MsBuild = {
        LoadProjectsONDemand = true,
      },
      RoslynExtensionsOptions = {
        EnableAnalyzersSupport = nil,
        EnableImportCompletion = nil,
        AnalyzeOpenDocumentsOnly = true,
      },
      Sdk = {
        IncludePrereleases = true,
      },
    },
  },
})

lsp.enable "buf_ls"

lsp.config("buf_ls", {
  cmd = { "bufls", "serve" },
  filetypes = { "proto" },
  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
})

lsp.enable "pyright"
lsp.config("pyright", {
  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        useLibraryCodeForTypes = true,
        inlayHints = {
          functionReturnTypes = true,
          variableTypes = true,
          parameterNames = true,
        },
      },
    },
  },
})

lsp.enable "html"
lsp.config("html", {
  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
})

lsp.enable "cssls"
lsp.config("cssls", {
  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
})

lsp.enable "clangd"
lsp.config("clangd", {
  cmd = { "clangd", "--background-index", "--clang-tidy" },
  filetypes = { "c", "cpp", "objc", "objcpp" },
  on_init = on_init,
  on_attach = function(client, bufnr)
    on_attach_extended(client, bufnr)
    client.offset_encoding = "utf-16"
  end,
  capabilities = cmp_capabilities,
  settings = {
    clangd = {
      inlayHints = {
        enabled = true,
        parameterNames = true,
        returnTypes = true,
        variableTypes = true,
      },
    },
  },
})

lsp.enable "pasls"
lsp.config("pasls", {
  cmd = { "pasls" },
  filetypes = { "pascal" },
  init_options = {
    fpcOptions = {
      "-Fu/usr/lib/fpc/3.2.2/units/x86_64-linux",
      "-Fu/usr/lib/fpc/3.2.2/units/x86_64-linux/rtl",
      "-Fi/usr/lib/fpc/3.2.2/units/x86_64-linux",
      "-Fi/usr/lib/fpc/3.2.2/units/x86_64-linux/rtl",
    },
    includeWorkspaceFoldersAsUnitPaths = true,
    includeWorkspaceFoldersAsIncludePaths = true,
  },
})

lsp.enable "lua_ls"
lsp.config("lua_ls", {
  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
  settings = {
    Lua = {
      runtime = {
        version = "LuaJIT",
      },
      diagnostics = {
        globals = { "vim" },
      },
      workspace = {
        library = vim.api.nvim_get_runtime_file("", true),
        checkThirdParty = false,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

lsp.enable "gradle_ls"
lsp.config("gradle_ls", {
  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
})

lsp.enable "prismals"
lsp.config("prismals", {
  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
})

lsp.enable "vue_ls"
lsp.config("vue_ls", {
  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
  filetypes = { "typescript", "javascript", "javascriptreact", "typescriptreact", "vue" },
  init_options = {
    vue = {
      hybridMode = false,
    },
  },
})
