local status, telescope = pcall(require, 'telescope')
if (not status) then return end
local builtin = require("telescope.builtin")

-- https://zenn.dev/fukakusa_kadoma/articles/4d48fb4e67c945
telescope.setup({
  defaults = {
    sorting_strategy = "ascending", -- 検索結果を上から下に並べる
    winblend = 4, --若干ウィンドウを透明に
    layout_strategy = 'vertical',
    layout_config = { height = 0.9 },
    file_ignore_patterns = { --検索対象に含めないファイルを指定
      ".git/",
      "node_modules/",
    },
  },
  extensions = {
  },
})
-- telescope.load_extension("frecency") --frecency search
-- telescope.load_extension("coc")      -- coc integration

-- file search
vim.keymap.set('n', '<leader>f',
  function()
    builtin.find_files({
      no_ignore = false,
      hidden = true
    })
  end)
-- -- Grep
vim.keymap.set('n', '<leader>r',
  function()
    builtin.live_grep({
      no_ignore = false,
      hidden = true
    })
  end)

--Telescope-coc
--定義ジャンプ
vim.keymap.set("n", "gd", "<cmd>Telescope coc definitions<cr>", { silent = true })
-- 型定義ジャンプ
vim.keymap.set("n", "gy", "<cmd>Telescope coc type_definitions<cr>", { silent = true })
-- diagnostics
vim.keymap.set("n", "<leader>a", "<cmd>Telescope coc diagnostics<cr>", { silent = true })
--頻度検索
vim.keymap.set("n", "<leader>l", "<cmd>telescope.extensions.frecency.frecency()<CR>", { noremap = true, silent = true })

