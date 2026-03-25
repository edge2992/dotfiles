local parsers = {
  "bash",
  "css",
  "dockerfile",
  "go",
  "html",
  "json",
  "lua",
  "markdown",
  "markdown_inline",
  "python",
  "rust",
  "toml",
  "tsx",
  "typescript",
  "yaml",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    lazy = false,
    build = ":TSUpdate",
    cond = vim.fn.has("nvim-0.10") == 1,
    config = function()
      local ts = require("nvim-treesitter")

      local to_install = {}
      for _, parser in ipairs(parsers) do
        if not pcall(vim.treesitter.language.add, parser) then
          table.insert(to_install, parser)
        end
      end
      if #to_install > 0 then
        ts.install(to_install)
      end

      vim.api.nvim_create_autocmd("FileType", {
        callback = function(args)
          local ft = args.match
          local lang = vim.treesitter.language.get_lang(ft) or ft
          local ok = pcall(vim.treesitter.language.inspect, lang)
          if ok then
            vim.treesitter.start()
            vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    lazy = false,
    cond = vim.fn.has("nvim-0.10") == 1,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    config = function()
      require("nvim-treesitter-textobjects").setup({
        select = {
          lookahead = true,
        },
        move = {
          set_jumps = true,
        },
      })

      local select = require("nvim-treesitter-textobjects.select")
      local move = require("nvim-treesitter-textobjects.move")
      local swap = require("nvim-treesitter-textobjects.swap")

      -- select
      vim.keymap.set({ "x", "o" }, "af", function() select.select_textobject("@function.outer") end)
      vim.keymap.set({ "x", "o" }, "if", function() select.select_textobject("@function.inner") end)
      vim.keymap.set({ "x", "o" }, "ac", function() select.select_textobject("@class.outer") end)
      vim.keymap.set({ "x", "o" }, "ic", function() select.select_textobject("@class.inner") end)
      vim.keymap.set({ "x", "o" }, "aa", function() select.select_textobject("@parameter.outer") end)
      vim.keymap.set({ "x", "o" }, "ia", function() select.select_textobject("@parameter.inner") end)

      -- move
      vim.keymap.set({ "n", "x", "o" }, "]f", function() move.goto_next_start("@function.outer") end)
      vim.keymap.set({ "n", "x", "o" }, "]c", function() move.goto_next_start("@class.outer") end)
      vim.keymap.set({ "n", "x", "o" }, "]a", function() move.goto_next_start("@parameter.inner") end)
      vim.keymap.set({ "n", "x", "o" }, "]F", function() move.goto_next_end("@function.outer") end)
      vim.keymap.set({ "n", "x", "o" }, "]C", function() move.goto_next_end("@class.outer") end)
      vim.keymap.set({ "n", "x", "o" }, "[f", function() move.goto_previous_start("@function.outer") end)
      vim.keymap.set({ "n", "x", "o" }, "[c", function() move.goto_previous_start("@class.outer") end)
      vim.keymap.set({ "n", "x", "o" }, "[a", function() move.goto_previous_start("@parameter.inner") end)
      vim.keymap.set({ "n", "x", "o" }, "[F", function() move.goto_previous_end("@function.outer") end)
      vim.keymap.set({ "n", "x", "o" }, "[C", function() move.goto_previous_end("@class.outer") end)

      -- swap
      vim.keymap.set("n", "<leader>a", function() swap.swap_next("@parameter.inner") end)
      vim.keymap.set("n", "<leader>A", function() swap.swap_previous("@parameter.inner") end)
    end,
  },
}
