-- base46 diagnostic/LSP highlight groups (Everforest Black); nvchad.configs.lspconfig is not used here
dofile(vim.g.base46_cache .. "lsp")

local lsp = vim.lsp

-- nvim only sends `shutdown` on exit and never kills the server; without a timeout node/gopls
-- servers outlive nvim as orphans (100-800 MB each). SIGTERM after 1.5s if still alive.
lsp.config("*", { exit_timeout = 1500 })
local root = require "utils.root"
local cmp_capabilities = require("cmp_nvim_lsp").default_capabilities()
cmp_capabilities.offsetEncoding = { "utf-16" }

-- Buffer-local LSP keymaps. Global equivalents (K, gd, gD, gi/gI, gr, gy,
-- <leader>lr, <leader>la, <leader>lf, <leader>ls ...) already live in
-- mappings.lua; only bind here what isn't covered there, so a key has one
-- clear meaning instead of two or three aliases.
local function on_attach_extended(client, bufnr)
  local function buf_map(mode, lhs, rhs, desc)
    vim.keymap.set(mode, lhs, rhs, { buffer = bufnr, desc = desc })
  end

  buf_map("n", "<leader>rc", vim.lsp.codelens.run, "Run CodeLens")
  buf_map("n", "<leader>cl", vim.lsp.codelens.run, "Run CodeLens (Alt)")
end

lsp.config("gopls", {
  -- -remote=auto: one shared gopls daemon per workspace instead of one per nvim (exits ~1 min after last client)
  cmd = { "gopls", "-remote=auto" },
  -- soft heap cap; the shared -remote=auto daemon inherits the environment
  cmd_env = { GOMEMLIMIT = "2GiB" },
  root_markers = { "go.work", "go.mod", ".git" },
  filetypes = { "go", "gomod", "gowork", "gotmpl" },
  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
  single_file_support = true,
  settings = {
    gopls = {
      gofumpt = true,
      completeUnimported = true,
      usePlaceholders = true,
      directoryFilters = { "-**/node_modules", "-**/.git", "-**/vendor" },
      semanticTokens = false,
      analyses = {
        unusedparams = true,
      },
      buildFlags = { "-tags=integration_database_test" },
    },
  },
})

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

lsp.config("protols", {
  cmd = { "protols" },
  filetypes = { "proto" },
  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
})

lsp.config("pyright", {
  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "basic",
        autoSearchPaths = true,
        diagnosticMode = "openFilesOnly",
        useLibraryCodeForTypes = false,
        exclude = { "**/node_modules", "**/.venv", "**/__pycache__" },
      },
    },
  },
})

lsp.config("cssls", {
  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
})

lsp.config("clangd", {
  cmd = { "clangd", "--background-index", "--clang-tidy", "-j=2", "--background-index-priority=low", "--malloc-trim", "--pch-storage=disk" },
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
        -- indexing the whole runtimepath (~90 plugin dirs) costs 0.5-1.5 GB per lua_ls
        library = { vim.env.VIMRUNTIME, "${3rd}/luv/library" },
        checkThirdParty = false,
        maxPreload = 2000,
        preloadFileSize = 200,
      },
      telemetry = {
        enable = false,
      },
    },
  },
})

lsp.config("gradle_ls", {
  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
})

lsp.config("prismals", {
  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
})

lsp.config("vue_ls", {
  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
  filetypes = { "vue" }, -- no ts plugin to pair with, so JS/TS buffers only spawned a useless node process
  init_options = {
    vue = {
      hybridMode = false,
    },
  },
})

lsp.config("html", {
  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
  filetypes = { "html" },
})

lsp.config("marksman", {
  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
  filetypes = { "markdown" },
})

lsp.config("typos_lsp", {
  cmd = { "typos-lsp" },
  cmd_env = {
    RUST_LOG = "error",
  },

  root_markers = {
    ".git",
    "typos.toml",
    ".typos.toml",
    "_typos.toml",
  },

  filetypes = {
    "go",
    "lua",
    "python",
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "markdown",
    "html",
    "css",
  },

  single_file_support = true,

  on_init = on_init,
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
})

-- YAML / JSON with SchemaStore catalogs (loaded when the server starts, not at nvim startup)
lsp.config("yamlls", {
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
  before_init = function(_, config)
    config.settings.yaml.schemas = require("schemastore").yaml.schemas()
  end,
  settings = {
    redhat = { telemetry = { enabled = false } },
    yaml = {
      keyOrdering = false,
      format = { enable = true },
      validate = true,
      schemaStore = { enable = false, url = "" }, -- replaced by the SchemaStore.nvim catalog
      schemas = {},
    },
  },
})

lsp.config("jsonls", {
  on_attach = on_attach_extended,
  capabilities = cmp_capabilities,
  before_init = function(_, config)
    config.settings.json.schemas = require("schemastore").json.schemas()
  end,
  settings = {
    json = {
      validate = { enable = true },
      schemas = {},
    },
  },
})

for _, name in ipairs { "dockerls", "docker_compose_language_service", "bashls", "taplo", "ts_ls" } do
  lsp.config(name, {
    on_attach = on_attach_extended,
    capabilities = cmp_capabilities,
  })
end

vim.lsp.enable "gopls"
vim.lsp.enable "dotnet"
vim.lsp.enable "protols"
vim.lsp.enable "pyright"
vim.lsp.enable "cssls"
vim.lsp.enable "clangd"
vim.lsp.enable "lua_ls"
vim.lsp.enable "gradle_ls"
vim.lsp.enable "prismals"
vim.lsp.enable "vue_ls"
vim.lsp.enable "html"
vim.lsp.enable "typos_lsp"
vim.lsp.enable "marksman"
vim.lsp.enable "yamlls"
vim.lsp.enable "jsonls"
vim.lsp.enable "dockerls"
vim.lsp.enable "docker_compose_language_service"
vim.lsp.enable "bashls"
vim.lsp.enable "taplo"
vim.lsp.enable "ts_ls"
