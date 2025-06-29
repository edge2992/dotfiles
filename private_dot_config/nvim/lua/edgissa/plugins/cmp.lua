return {
  "hrsh7th/nvim-cmp",
  dependencies = {
    "hrsh7th/cmp-buffer", -- Buffer completions
    "hrsh7th/cmp-path", -- Path completions
    "L3MON4D3/LuaSnip", -- Snippet engine
    "hrsh7th/cmp-nvim-lsp", -- LSP completions
    "onsails/lspkind-nvim", -- LSP icons
  },
  config = function()
    local cmp = require("cmp")
    local lspkind = require("lspkind")

    cmp.setup({
      snippet = {
        expand = function(args)
          require("luasnip").lsp_expand(args.body) -- For luasnip users
        end,
      },
      mapping = cmp.mapping.preset.insert({
        ["<C-n>"] = cmp.mapping.select_next_item(),
        ["<C-p>"] = cmp.mapping.select_prev_item(),
        ["<C-d>"] = cmp.mapping.scroll_docs(-4),
        ["<C-f>"] = cmp.mapping.scroll_docs(4),
        ["<C-Space>"] = cmp.mapping.complete(),
        ["<CR>"] = cmp.mapping.confirm({ select = true }),
        ["<C-e>"] = cmp.mapping.abort(),
      }),
      sources = {
        { name = "nvim_lsp" },
        { name = "buffer" },
        { name = "path" },
      },
      formatting = {
        format = lspkind.cmp_format({
          mode = "symbol_text", -- show both symbol and text
          maxwidth = 50, -- prevent the popup from showing too many characters
          ellipsis_char = "...", -- fallback for when the text is too long
        }),
      },
    })
  end,
}
