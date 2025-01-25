local status, wk = pcall(require, "which-key")
if not status then
	return
end

wk.setup({
	triggers = "auto",
})

wk.add({
	{ "<leader>f", group = "Telescope" },
	{ "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
	{ "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
	{ "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
	{ "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
	{ "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle Neotree" },
	{ "<leader>o", "<cmd>Neotree forcus<cr>", desc = "Forcus on Neotree" },
	{ "<leader>q", "<cmd>q<br>", desc = "Quit" },
	{ "<leader>j", group = "Hop Word" },
	{ "<leader>jh", "<cmd>HopWord<cr>", desc = "Hop" },
	{ "<leader>jl", "<cmd>HopLine<cr>", desc = "Hop Line" },
	{ "<leader>jf", "<cmd>HopWordAC<cr>", desc = "Hop Word AC" },
	{ "<leader>jF", "<cmd>HopWordBC<cr>", desc = "Hop Word BC" },
})
