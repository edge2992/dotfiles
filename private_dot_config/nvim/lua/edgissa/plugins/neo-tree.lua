return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  config = function()
    local neo_tree = require("neo-tree")
    local keymap = vim.keymap

    neo_tree.setup({
      close_if_last_window = true,
      enable_git_status = true,
      enable_diagnostics = true,
      default_component_configs = {
        indent = {
          with_markers = true,
        },
      },
    })

    keymap.set("n", "<leader>e", ":Neotree toggle<Return>", { desc = "Toggle Neo-tree" })
    keymap.set("v", "<leader>e", ":Neotree toggle<Return>", { desc = "Toggle Neo-tree" })
  end,
}
