# markview.nvim Integration Design

## Goal

Add markview.nvim to the Neovim configuration to improve Markdown readability within the editor. Primary use case: reading Claude-generated Markdown (CLAUDE.md, chat outputs, documentation).

## Design Decisions

- **Plugin**: `OXY2DEV/markview.nvim` — actively maintained, supports Markdown/HTML/LaTeX/Typst
- **Approach**: Minimal configuration, rely on plugin defaults
- **Insert mode**: Hybrid mode — show raw Markdown on the current line while editing, render everything else
- **Lazy loading**: `lazy = false` per plugin recommendation (plugin handles its own lazy loading internally)
- **Dependencies**: `nvim-web-devicons` already available via neo-tree

## Implementation

### New file: `private_dot_config/nvim/lua/edgissa/plugins/markview.lua`

```lua
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
```

### Configuration rationale

| Setting | Value | Reason |
|---------|-------|--------|
| `lazy` | `false` | Plugin docs warn against lazy-loading; it self-manages |
| `cond` | `vim.fn.has("nvim-0.10") == 1` | Requires Neovim >= 0.10; matches treesitter.lua pattern |
| `modes` | `{ "n", "no", "c" }` | Render in normal/operator-pending/command modes (default) |
| `hybrid_modes` | `{ "n" }` | In normal mode, show raw source on cursor line for easy reading of actual syntax |
| `linewise_hybrid_mode` | `true` | Only un-render the current line, not the whole block |

Insert mode is NOT in `modes`, so entering insert mode automatically shows raw Markdown — matching user preference (A).

### No changes needed

- TreeSitter `markdown` and `markdown_inline` parsers: already installed
- `nvim-web-devicons`: already a dependency of neo-tree (markview.nvim's default `icon_provider` is `"internal"`, so it works without devicons too)
- Colorscheme: markview.nvim auto-generates highlight groups from the active colorscheme (catppuccin mocha)

## Verification

1. `chezmoi diff` — confirm only the new file is added
2. `chezmoi apply` — apply to home directory
3. Open a `.md` file in Neovim — confirm headings, code blocks, tables render
4. Enter insert mode — confirm raw Markdown is shown
5. `:Markview` — confirm toggle works

## Scope

- Single new file addition
- No changes to existing configuration
- No new dependencies to install
