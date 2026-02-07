local M = {}

function M.find(bufnr)
  local markers = {
    "go.work",
    "go.mod",
    "Cargo.toml",
    "package.json",
    "tsconfig.json",
    "pyproject.toml",
    "requirements.txt",
    "setup.py",
    "manage.py",
    "composer.json",
    "*.csproj",
    "*.sln",
    "pom.xml",
    "build.gradle",
    "settings.gradle",
    "gradlew",
    "Gemfile",
    "Makefile",
    ".git",
  }

  return vim.fs.root(bufnr, markers)
end

return M
