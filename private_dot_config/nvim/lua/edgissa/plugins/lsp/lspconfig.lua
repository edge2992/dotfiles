-- nvim-lspconfig prividing LSP support for Neovim
-- nvim-lspconfig does not have LSP client implementation, it only provides configuration templates.
-- LSP client implementation is provided by Neovim itself.
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim", -- LSP server installer
    "williamboman/mason-lspconfig.nvim", -- Integration between mason and nvim-lspconfig
    "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
  },
  config = function()
    local cmp_nvim_lsp = require('cmp_nvim_lsp')
    local mason_lspconfig = require('mason-lspconfig')
    local lspconfig = require('lspconfig')


    local on_attach = function(_, bufnr)
      local map = function(lhs, rhs, desc)
        vim.keymap.set("n", lhs, rhs, { buffer = bufnr, silent = true, desc = "LSP: " .. desc })
      end

      -- Key mappings for LSP actions
      map("gd",  vim.lsp.buf.definition,  "Go to definition")
      map("K",   vim.lsp.buf.hover,       "Hover")
      map("<F2>",vim.lsp.buf.rename,      "Rename")
      map("<F4>",vim.lsp.buf.code_action, "Code Action")
    end

    local capabilities = cmp_nvim_lsp.default_capabilities()

    mason_lspconfig.setup({
      handlers = {
        -- Default handler for LSP servers
        function(server_name)
          lspconfig[server_name].setup({
            on_attach = on_attach,
            capabilities = capabilities,
          })
        end,
      },
    })
  end,
}
