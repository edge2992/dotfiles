return {
  "L3MON4D3/LuaSnip",
  version = "v2.*",
  build = "make install_jsregexp",
  dependencies = {
    "rafamadriz/friendly-snippets",
    "saadparwaiz1/cmp_luasnip",
  },
  config = function()
    require("luasnip.loaders.from_vscode").lazy_load()
  end,
}
