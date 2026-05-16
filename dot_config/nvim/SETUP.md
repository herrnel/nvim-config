# Neovim Setup

This config is managed by **chezmoi**. The source of truth lives in
`~/.local/share/chezmoi/dot_config/nvim/`. Editing files in
`~/.config/nvim/` directly will be **overwritten** on the next
`chezmoi apply`. Use `chezmoi edit <file>` or edit in the source
directory and `chezmoi apply`.

## Layout

```
~/.config/nvim/
├── init.lua                 # Entry point; wires up everything in lua/user/
├── lazy-lock.json           # Pinned plugin commits (committed to dotfiles)
├── nvim-pack-lock.json      # Built-in vim.pack lockfile (unused; lazy.nvim drives plugins)
├── SETUP.md                 # This file
└── lua/user/
    ├── options.lua          # Core vim.o settings, leader, autocmds
    ├── keymaps.lua          # Global keymaps
    ├── plugins.lua          # lazy.nvim bootstrap + plugin spec list
    ├── treesitter.lua       # nvim-treesitter setup (loaded early)
    ├── lsp.lua              # nvim-lspconfig + mason
    ├── completion.lua       # nvim-cmp + LuaSnip
    ├── telescope.lua        # Fuzzy finder
    ├── whichkey.lua         # which-key prompts
    ├── explorer.lua         # nvim-tree
    ├── markdown.lua         # render-markdown.nvim
    └── theme.lua            # Colorscheme (vague → rose-pine → catppuccin fallback)
```

`init.lua` loads modules in this order — order matters:

1. `options`, `keymaps`        (must run before plugins so `mapleader` is set)
2. `plugins`                   (lazy.nvim bootstraps + installs plugins)
3. `treesitter`, `lsp`, `completion`, `telescope`
4. `whichkey`, `explorer`, `markdown`
5. `theme`                     (last, after all UI plugins are configured)

## Plugin manager

[lazy.nvim](https://github.com/folke/lazy.nvim) — auto-bootstrapped from
`lua/user/plugins.lua` on first run. Plugin versions are pinned in
`lazy-lock.json`.

Useful commands:

| Command         | Purpose                              |
| --------------- | ------------------------------------ |
| `:Lazy`         | Open the plugin UI                   |
| `:Lazy sync`    | Install / update / clean plugins     |
| `:Lazy update`  | Update all plugins                   |
| `:Lazy restore` | Reset plugins to `lazy-lock.json`    |
| `:Mason`        | LSP server installer UI              |
| `:checkhealth`  | Diagnose nvim / plugin issues        |

## Installed plugins

| Plugin                                   | Purpose                                  |
| ---------------------------------------- | ---------------------------------------- |
| `nvim-lua/plenary.nvim`                  | Common Lua utility lib (dependency)      |
| `nvim-treesitter/nvim-treesitter`        | Syntax-aware highlighting & parsing      |
| `neovim/nvim-lspconfig` + Mason          | LSP config + automatic server install    |
| `hrsh7th/nvim-cmp` (+ sources, LuaSnip)  | Autocompletion + snippets                |
| `nvim-tree/nvim-tree.lua`                | File explorer sidebar                    |
| `nvim-telescope/telescope.nvim`          | Fuzzy finder (files, grep, buffers…)     |
| `folke/which-key.nvim`                   | Popup showing pending keybindings        |
| `catppuccin/nvim`                        | Colorscheme (fallback #2)                |
| `rose-pine/neovim`                       | Colorscheme (fallback #1)                |
| `vague2k/vague.nvim`                     | Colorscheme (**primary**)                |
| `christoomey/vim-tmux-navigator`         | `Ctrl-h/j/k/l` between nvim & tmux panes |
| `MeanderingProgrammer/render-markdown`   | Pretty in-buffer markdown rendering      |

## Theme

Primary: **vague** (`vague2k/vague.nvim`). Configured in `lua/user/theme.lua`.
Falls back to `rose-pine` then `catppuccin` if vague isn't installed.

vague's API only accepts: `transparent`, `bold`, `italic`, `colors`,
`on_highlights`. Per-group style tweaks (e.g. italic comments,
bold types) are done via `on_highlights = function(hl, c) ... end`.
There is **no** top-level `style = { ... }` table — that's an old/foreign API.

### Truecolor requirements

vague uses 24-bit hex colors. Two things must be true or the theme will
silently render in basic ANSI colors:

1. `vim.o.termguicolors = true`  (set in `lua/user/options.lua`)
2. The terminal (and tmux) must advertise truecolor.

Inside tmux, `~/.tmux.conf` must include:

```tmux
set -g default-terminal "tmux-256color"
set -as terminal-features ",xterm-256color:RGB"
set -as terminal-features ",tmux-256color:RGB"
set -as terminal-overrides ",*256col*:Tc"
```

Verify after a fresh tmux session:

```vim
:echo &termguicolors            " expect 1
:lua print(vim.env.COLORTERM)   " expect 'truecolor' (set by outer terminal)
```

If `COLORTERM` is empty, `export COLORTERM=truecolor` in your shell rc.

## Working with chezmoi

```bash
chezmoi edit ~/.config/nvim/lua/user/theme.lua   # edit in source, then prompts to apply
chezmoi diff                                     # see drift between source and live
chezmoi re-add <file>                            # push live edits back into source
chezmoi apply                                    # write source → live
chezmoi cd                                       # cd into the source dir
```

When experimenting, edit the live file first, then `chezmoi re-add` once happy.

## Bootstrapping on a new machine

```bash
chezmoi init --apply <your-dotfiles-repo>
nvim                       # lazy.nvim auto-installs and syncs plugins on first launch
:Lazy restore              # pin to lazy-lock.json versions
:Mason                     # install desired LSP servers
```

## Troubleshooting

| Symptom                          | Likely cause / fix                                              |
| -------------------------------- | --------------------------------------------------------------- |
| Theme looks washed out / 16-color | `termguicolors` off, or tmux not advertising RGB. See above.   |
| `vague` not found                | `:Lazy sync`. Confirm spec exists in `plugins.lua`.             |
| Edits keep disappearing          | You edited the live file; chezmoi reverted it. `chezmoi re-add`.|
| LSP not attaching                | `:Mason` to install server; `:LspInfo` to inspect.              |
| `Ctrl-h/j/k/l` doesn't navigate  | Confirm `vim-tmux-navigator` plugin loaded **and** the matching tmux bindings in `~/.tmux.conf`. |
