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
      -- Keep list text in its raw column so toggling hybrid/insert mode doesn't shift it
      markdown = {
        list_items = {
          marker_minus = { add_padding = false, conceal_on_checkboxes = false },
          marker_plus = { add_padding = false, conceal_on_checkboxes = false },
          marker_star = { add_padding = false, conceal_on_checkboxes = false },
          marker_dot = { add_padding = false, conceal_on_checkboxes = false },
          marker_parenthesis = { add_padding = false, conceal_on_checkboxes = false },
        },
      },
      -- Pad icons to the 3-cell width of "[ ]" / "[x]"
      markdown_inline = {
        checkboxes = {
          checked = { text = " 󰗠 " },
          unchecked = { text = " 󰄰 " },
        },
      },
    })
  end,
}
