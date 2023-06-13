local function map(mode, lhs, rhs)
	vim.keymap.set(mode, lhs, rhs, { silent = true })
end

-- Exit insert mode
map("i", "jk", "<ESC>")

-- Buffer
map("n", "<TAB>", "<CMD>bnext<CR>")
map("n", "<S-TAB>", "<CMD>bprevious<CR>")

-- Window Navigation
map("n", "<C-h>", "<C-w>h")
map("n", "<C-l>", "<C-w>l")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-j>", "<C-w>j")

-- Move Line Up and Down
map("n", "<A-j>", "<Esc>:m .+1<CR>==")
map("n", "<A-k>", "<Esc>:m .-2<CR>==")

-- Resize Windows
map("n", "<C-Left>", "<C-w><")
map("n", "<C-Right>", "<C-w>>")
map("n", "<C-Up>", "<C-w>+")
map("n", "<C-Down>", "<C-w>-")

-- LSP
-- https://github.com/LunarVim/Neovim-from-scratch/blob/master/lua/user/lsp/handlers.lua
map("n", "gD", vim.lsp.buf.declaration)
map("n", "gd", vim.lsp.buf.definition)
map("n", "K", vim.lsp.buf.hover)
map("n", "gI", vim.lsp.buf.implementation)
map("n", "gr", vim.lsp.buf.references)
map("n", "gl", vim.diagnostic.open_float)

-- <leader> = the space key

local status, telescope = pcall(require, "telescope.builtin")
local mappings = {}
if status then
	-- Telescope
	mappings["f"] = {
		name = "+telescope",
		f = { telescope.find_files, "Find Files" },
		g = { telescope.live_grep, "Live Grep" },
		b = { telescope.buffers, "Buffers" },
		h = { telescope.help_tags, "Help Tags" },
		n = { telescope.notifications, "Notifications" },
		s = { telescope.git_status, "Git Status" },
		c = { telescope.git_commits, "Git Commits" },
	}
else
	print("Telescope not found")
end

-- Save
mappings["w"] = { "<CMD>update<CR>", "Save" }

-- Quit
mappings["q"] = { "<CMD>q<CR>", "Quit" }

-- Windows
mappings["n"] = { "<CMD>vsplit<CR>", "New Vertical Split" }
mappings["p"] = { "<CMD>split<CR>", "New Horizontal Split" }

-- NeoTree
-- TODO: when forcus is attached to neo-tree filesystem, registered command cannot use.
-- The reason may be whcih-key plugin does not work at moditable off buffer.
mappings["e"] = { "<CMD>Neotree toggle<CR>", "Toggle NeoTree" }
mappings["o"] = { "<CMD>Neotree focus<CR>", "Focus on NeoTree" }

-- Terminal
mappings["t"] = {
	name = "+terminal",
	h = { "<CMD>ToggleTerm size=10 direction=horizontal<CR>", "Toggle Horizontal Terminal" },
	v = { "<CMD>ToggleTerm size=80 direction=vertical<CR>", "Toggle Vertical Terminal" },
}

-- Markdown Preview
mappings["m"] = {
	name = "+markdown",
	m = { "<CMD>MarkdownPreview<CR>", "Preview Markdown" },
	n = { "<CMD>MarkdownPreviewStop<CR>", "Stop Markdown Preview" },
}

-- LSP
mappings["l"] = {
	"+lsp",
	f = { "<CMD>lua vim.lsp.buf.format{ async = true }<CR>", "Format" },
	i = { "<CMD>LspInfo<CR>", "LspInfo" },
	a = { "<CMD>lua vim.lsp.buf.code_action()<CR>", "Code Action" },
	j = { "<CMD>lua vim.diagnostic.goto_next({buffer=0})<CR>", "Goto Next Diagnostic" },
	k = { "<CMD>lua vim.diagnostic.goto_prev({buffer=0})<CR>", "Goto Prev diagnositic" },
	r = { "<CMD>lua vim.lsp.buf.rename()<CR>", "Rename" },
	s = { "<CMD>lua vim.lsp.buf.signature_help()<CR>", "Signature Help" },
	q = { "<CMD>lua vim.diagnostic.setloclist()<CR>", "Set Loc List" },
	-- I = { "<CMD>LspInstallInfo<CR>", "LspInstallInfo" },
}

-- Hop (EasyMotion)
mappings["j"] = {
	name = "+hop word",
	h = { "<CMD>HopWord<CR>", "Hop" },
	f = { "<CMD>HopWordAC<CR>", "Hop Front" },
	F = { "<CMD>HopWordBC<CR>", "Hop Back" },
}

local status, which_key = pcall(require, "which-key")
if not status then
	return
end

local opts = {
	mode = "n", -- NORMAL mode
	prefix = "<leader>",
	buffer = nil, -- Global mappings. Specify a buffer number for buffer local mappings
	silent = true, -- use `silent` when creating keymaps
	noremap = true, -- use `noremap` when creating keymaps
	nowait = true, -- use `nowait` when creating keymaps
}

which_key.register(mappings, opts)
