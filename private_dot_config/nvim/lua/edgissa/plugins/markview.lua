return {
  "OXY2DEV/markview.nvim",
  lazy = false,
  cond = vim.fn.has("nvim-0.10") == 1,
  config = function()
    require("markview").setup({
      preview = {
        modes = { "n", "no", "c" },
        hybrid_modes = { "n" },
        linewise_hybrid_mode = true,
      },
    })
  end,
}
