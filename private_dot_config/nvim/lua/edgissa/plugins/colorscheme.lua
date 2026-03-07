return {
  "catppuccin/nvim",
  name = "catppuccin",
  priority = 1000,
  config = function()
    require("catppuccin").setup({
      flavour = "mocha",
      integrations = {
        cmp = true,
        gitsigns = true,
        treesitter = true,
        telescope = { enabled = true },
        diffview = true,
        neotree = true,
        which_key = true,
        native_lsp = {
          enabled = true,
        },
      },
    })

    vim.cmd.colorscheme("catppuccin-mocha")
  end,
}
