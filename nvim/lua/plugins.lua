-- Automatically run: PackerCompile
vim.api.nvim_create_autocmd("BufWritePost", {
	group = vim.api.nvim_create_augroup("PACKER", { clear = true }),
	pattern = "plugins.lua",
	command = "source <afile> | PackerCompile",
})

return require("packer").startup(function(use)
	-- Packer
	use("wbthomason/packer.nvim")

	-- Common utilities
	use("nvim-lua/plenary.nvim")

	-- Icons
	use("nvim-tree/nvim-web-devicons")

	-- Colorschema
	use("altercation/vim-colors-solarized")

	-- Statusline
	use({
		"nvim-lualine/lualine.nvim",
		event = "BufEnter",
		config = function()
			require("configs.lualine")
		end,
		requires = { "nvim-web-devicons" },
	})

	-- show notification
	use({
		"rcarriga/nvim-notify",
		config = function()
			require("configs.notify")
		end,
	})

	-- Show Bufferline
	use({
		"akinsho/bufferline.nvim",
		tag = "*",
		config = function()
			require("configs.bufferline")
		end,
		requires = { "nvim-web-devicons" },
	})

	-- Show Leader Commands
	use({
		"folke/which-key.nvim",
		config = function()
			vim.o.timeout = true
			vim.o.timeoutlen = 0
			require("configs.which-key")
		end,
		requires = { "echasnovski/mini.nvim" },
	})

	-- easyMotion
	use({
		"phaazon/hop.nvim",
		branch = "v2",
		config = function()
			require("configs.hop")
		end,
	})

	-- Treesitter
	use({
		"nvim-treesitter/nvim-treesitter",
		run = ":TSUpdate",
		config = function()
			require("configs.treesitter")
		end,
	})

	use({ "nvim-treesitter/playground" })

	-- Telescope
	-- TODO: use fzf to fussy search
	-- use({ "nvim-telescope/telescope-fzf-native.nvim", run = "make" })
	use({
		"nvim-telescope/telescope.nvim",
		tag = "0.1.x",
		requires = {
			"nvim-lua/plenary.nvim",
			{ "nvim-telescope/telescope-fzf-native.nvim", run = "make" },
			"nvim-telescope/telescope-ghq.nvim",
		},
		config = function()
			require("configs.telescope")
		end,
	})

	-- LSP
	use({
		"neovim/nvim-lspconfig",
		config = function()
			require("configs.lsp")
		end,
	})

	use("onsails/lspkind-nvim")

	-- TODO: how to use?
	use({
		"j-hui/fidget.nvim",
		confing = function()
			require("fidget").setup()
		end,
	})

	-- snippet
	use({ "L3MON4D3/LuaSnip" })
	-- cmp: Autocomplete
	use({
		"hrsh7th/nvim-cmp",
		event = "InsertEnter",
		config = function()
			require("configs.cmp")
		end,
	})

	use({
		"hrsh7th/cmp-nvim-lsp",
		-- after = "nvim-cmp",
	})
	use({ "hrsh7th/cmp-path", after = "nvim-cmp" })
	use({ "hrsh7th/cmp-buffer", after = "nvim-cmp" })

	-- Copilot, AI pair programmer
	-- To use this plugin, invoke `:Copilot setup`
	use({ "github/copilot.vim" })

	-- LSP diagosticsm, code actions, and more via lua
	use({
		"jose-elias-alvarez/null-ls.nvim",
		config = function()
			require("configs.null-ls")
		end,
		requires = { "nvim-lua/plenary.nvim" },
	})

	use({
		"folke/trouble.nvim",
		requires = { "nvim-tree/nvim-web-devicons" },
	})

	-- Mason: Portable package manager
	use({
		"williamboman/mason.nvim",
		config = function()
			require("mason").setup()
		end,
	})

	use({
		"williamboman/mason-lspconfig.nvim",
		config = function()
			require("configs.mason-lsp")
		end,
		after = { "mason.nvim", "cmp-nvim-lsp" },
	})

	-- File manager
	use({
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v2.x",
		requires = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
		},
	})

	-- Show colors
	use({
		"norcalli/nvim-colorizer.lua",
		config = function()
			require("colorizer").setup({ "*" })
		end,
	})

	-- Show Indent Lines
	use({
		"lukas-reineke/indent-blankline.nvim",
	})

	-- Terminal
	use({
		"akinsho/toggleterm.nvim",
		tag = "*",
		config = function()
			require("configs.toggleterm")
		end,
	})

	-- Git
	use({
		"lewis6991/gitsigns.nvim",
		config = function()
			require("configs.gitsigns")
		end,
	})

	use({ "tpope/vim-fugitive" })

	use({
		"akinsho/git-conflict.nvim",
		tag = "*",
	})

	-- Markdown Preview
	use({
		"iamcco/markdown-preview.nvim",
		run = function()
			vim.fn["mkdp#util#install"]()
		end,
	})

	-- autoPairs
	use({
		"windwp/nvim-autopairs",
		config = function()
			require("configs.autopairs")
		end,
	})

	-- comment out
	use("tpope/vim-commentary")
end)
