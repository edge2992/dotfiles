return {
  "nvim-lualine/lualine.nvim",
  dependencies = {
    "nvim-tree/nvim-web-devicons",
  },
  config = function()
    local lualine = require("lualine")
    local lazy_status = require("lazy.status")
    local fcitx5 = require("edgissa.core.fcitx5")

    lualine.setup({
      options = {
        icons_enabled = true,
        theme = "auto",
      },
      sections = {
        lualine_x = {
          {
            lazy_status.updates,
            cond = lazy_status.has_updates,
            color = { fg = "#ff9e64" },
          },
        },
        lualine_y = {
          {
            fcitx5.lualine_component,
            color = { fg = "#f38ba8" },
          },
        },
      },
    })
  end,
}
