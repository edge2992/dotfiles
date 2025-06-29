return {
  "williamboman/mason.nvim",
  dependencies = {
    "williamboman/mason-lspconfig.nvim",
    "WhoIsSethDaniel/mason-tool-installer.nvim",
  },
  cmd = { "Mason", "MasonInstall", "MasonUninstall" },
  build = ":MasonUpdate",
  config = function()
    local mason = require("mason")
    local mason_lspconfig = require("mason-lspconfig")
    local mason_tool_installer = require("mason-tool-installer")

    mason.setup({
      ui = {
        border = "rounded",
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    })

    -- Setup LSP servers and tools
    mason_lspconfig.setup({
      ensure_installed = {
        "bashls",
        "cssls",
        "dockerls",
        "gopls",
        "html",
        "jsonls",
        "lua_ls",
        "pyright",
        "sqlls",
        "zls",
      },
      automatic_installation = true,
    })

    -- Setup tools (MasonInstall and MasonUpdate)
    mason_tool_installer.setup({
      ensure_installed = {
        "prettier",
        "stylua",
        "shfmt",
        "shellcheck",
        "goimports",
        "sql-formatter",
        "eslint_d",
        "black",
        "isort",
      },
      auto_update = true, -- MasonUpdate --outdated --quit
      run_on_start = true, -- Automatically install tools on startup
    })
  end,
}
