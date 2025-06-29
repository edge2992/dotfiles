-- nvim-lspconfig prividing LSP support for Neovim
-- nvim-lspconfig does not have LSP client implementation, it only provides configuration templates.
-- LSP client implementation is provided by Neovim itself.
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" }, -- Load on buffer read or new file
  dependencies = {
    "williamboman/mason.nvim", -- LSP server installer
    "williamboman/mason-lspconfig.nvim", -- Integration between mason and nvim-lspconfig
    "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
  },
  config = function()
    local cmp_nvim_lsp = require('cmp_nvim_lsp')
    local mason_lspconfig = require('mason-lspconfig')

    local on_attach = function(_, bufnr)
      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = "LSP: " .. desc })
      end

      -- Key mappings for LSP actions
      map("gd",  vim.lsp.buf.definition,  "Go to definition")
      map("K",   vim.lsp.buf.hover,       "Hover")
      map("<F2>",vim.lsp.buf.rename,      "Rename")
      map("<F4>",vim.lsp.buf.code_action, "Code Action")

      -- Pop up diagnostics
      map("gl", vim.diagnostic.open_float, "Line Diagnostics")

      -- Jump to diagnostics
      map("[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, "Prev Diagnostic")
      map("]d", function() vim.diagnostic.jump({ count =  1, float = true }) end, "Next Diagnostic")
    end

    local capabilities = cmp_nvim_lsp.default_capabilities()

    mason_lspconfig.setup({
      ensure_installed = {
        "bashls",      -- Bash language server
        "cssls",       -- CSS language server
        "html",        -- HTML language server
        "jsonls",      -- JSON language server
        "pyright",     -- Python language server
        "lua_ls",      -- Lua language server
        "gopls",       -- Go language server
      },
    })

    -- neovim v0.11+ and mason-lspconfig v2
    -- default configuration for all LSP servers
    vim.lsp.config("*", {
      on_attach = on_attach,
      capabilities = capabilities,
    })

    vim.lsp.config('lua_ls', {
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' }, -- Recognize 'vim' as a global variable
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true), -- Include Neovim runtime files
          },
        },
      },
    })
  end,
}
