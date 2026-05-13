# Your Neovim Setup — Rundown

## 📁 Structure

```
~/.config/nvim/
├── init.lua              # Entry point – loads modules in order
├── lazy-lock.json        # Pinned plugin versions (commit this!)
├── lua/user/
│   ├── options.lua       # Core vim options + leader key
│   ├── keymaps.lua       # Global keymaps
│   ├── plugins.lua       # lazy.nvim bootstrap + plugin list
│   ├── treesitter.lua    # Syntax highlighting / parsers
│   ├── lsp.lua           # Mason + LSP servers + keymaps
│   ├── completion.lua    # nvim-cmp autocomplete + snippets
│   ├── telescope.lua     # Fuzzy finder
│   ├── whichkey.lua      # Leader-key popup helper
│   ├── explorer.lua      # nvim-tree file explorer
│   └── theme.lua         # Catppuccin (mocha)
├── after/ ftplugin/ plugin/ syntax/   (currently empty)
└── nvim-pack-lock.json
```

## ✨ What You Can Do With It

**Core editing**
- Leader key = `<Space>`
- Relative + absolute line numbers, cursorline, OS clipboard sync, smart case search
- Highlight-on-yank, `:GitBlameLine` custom command
- Window nav with `<Alt-h/j/k/l>` (works in normal, insert, terminal modes)
- `<Esc>` exits terminal mode

**LSP (auto-installed via Mason)**
- Languages: Lua, Python, TypeScript/JS, Rust, Go, C/C++
- `gd` definition · `gD` declaration · `gi` implementation · `gr` references
- `K` hover · `<C-k>` signature · `<leader>rn` rename · `<leader>ca` code action · `<leader>lf` format
- Diagnostic icons in sign column, virtual text with `●`

**Autocomplete (nvim-cmp)**
- Sources: LSP, LuaSnip snippets, buffer, path
- `<Tab>/<S-Tab>` cycle · `<CR>` confirm · `<C-Space>` trigger · `<C-b>/<C-f>` scroll docs
- Command-line completion enabled too

**Treesitter** — modern highlighting + indent for 15+ languages, `<CR>`/`<BS>` for incremental selection.

**Telescope (`<leader>f…`)**
- `ff` files · `fg` live grep · `fb` buffers · `fh` help · `fr` recent files · `fd`/`fr` LSP defs/refs

**Other**
- `<leader>e` toggle nvim-tree file explorer
- `<leader>b{n,p,d}` buffer next/prev/delete
- which-key popup shows all `<leader>` mappings as you type
- Catppuccin Mocha theme

---

## 🚀 Sharing Across Devices via Git

### One-time setup on this machine

```bash
cd ~/.config/nvim

# .gitignore – keep noise out
cat > .gitignore <<'EOF'
# Plugin install dirs live in stdpath('data'), not here, so nothing to ignore there.
# But just in case:
.luarc.json
*.log
EOF

git init -b main
git add .
git commit -m "Initial nvim config"

# Create an empty repo on GitHub first (no README), then:
git remote add origin git@github.com:<your-username>/nvim-config.git
git push -u origin main
```

**Important:** commit `lazy-lock.json` — it pins plugin versions so every machine gets the exact same setup. Run `:Lazy restore` on a new machine to honor it, or `:Lazy sync` to update.

### On a new machine

```bash
# Back up anything existing
mv ~/.config/nvim ~/.config/nvim.bak 2>/dev/null

git clone git@github.com:<your-username>/nvim-config.git ~/.config/nvim
nvim           # lazy.nvim bootstraps, installs plugins
# In nvim: :Lazy restore   then   :Mason   to verify LSP servers
```

### Suggested daily workflow

1. Edit config in nvim, test, commit:
   ```bash
   cd ~/.config/nvim && git add -A && git commit -m "tweak: ..." && git push
   ```
2. On other machines: `cd ~/.config/nvim && git pull && nvim +":Lazy sync" +qa`
3. Use **branches** for experiments (`git checkout -b try-lualine`) so you can roll back easily.
4. Keep machine-specific stuff out of tracked files — put it in `lua/user/local.lua` and add to `.gitignore`, then `pcall(require, 'user.local')` from `init.lua`.
5. Optional: manage with [`chezmoi`](https://chezmoi.io) or GNU `stow` if you want to bundle nvim with your other dotfiles (`.zshrc`, `tmux.conf`, etc.) in one repo.

---

## 🪟 Adding Tmux Support

There's nothing tmux-specific in your config yet. The most useful additions:

**1. Install tmux** (`sudo apt install tmux` / `brew install tmux`).

**2. Seamless pane navigation between nvim splits & tmux panes** — add to `lua/user/plugins.lua`:

```lua
{ "christoomey/vim-tmux-navigator", lazy = false },
```

Then in `~/.tmux.conf`:

```tmux
# Smart pane switching with awareness of Vim splits.
is_vim="ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
bind -n C-h if-shell "$is_vim" "send-keys C-h" "select-pane -L"
bind -n C-j if-shell "$is_vim" "send-keys C-j" "select-pane -D"
bind -n C-k if-shell "$is_vim" "send-keys C-k" "select-pane -U"
bind -n C-l if-shell "$is_vim" "send-keys C-l" "select-pane -R"

# True color + undercurl
set -g default-terminal "tmux-256color"
set -as terminal-features ",xterm-256color:RGB"
set -g focus-events on
set -sg escape-time 10
```

This gives you `Ctrl-h/j/k/l` to jump across both nvim splits *and* tmux panes uniformly — note this differs from your current `<Alt-…>` mappings, so they happily coexist.

**3. Optional plugins**
- `aserowy/tmux.nvim` — copy-mode integration & resizing
- `preservim/vimux` — run shell commands in a tmux pane from nvim

**4. Nice quality-of-life tmux config**
```tmux
set -g mouse on
set -g base-index 1
setw -g pane-base-index 1
set -g history-limit 50000
```

Recommended workflow: `tmux new -s dev` → split panes → run nvim in one, dev server / tests in others. Detach with `Ctrl-b d`, reattach later with `tmux attach -t dev`. Survives SSH disconnects.

---

## 👻 Does Ghostty Support Windows?

**Not officially, no.** As of now (2026):

- Ghostty officially supports **macOS** and **Linux** only.
- **Windows is not supported.** Mitchell Hashimoto has said Windows is a long-term goal but is not a near-term priority; the GTK backend isn't viable on Windows and a native backend would need to be written.
- Workarounds on Windows:
  - Use **WSL2** + a Linux terminal (you still need a Windows host terminal to display it — Ghostty doesn't run there).
  - Use alternatives with similar GPU-accelerated feel: **WezTerm**, **Alacritty**, or the new **Windows Terminal** (all support true color, ligatures, undercurl — everything your nvim setup wants).

If you're trying to keep a consistent terminal across Mac/Linux/Windows, **WezTerm** is the closest cross-platform analogue to Ghostty and pairs beautifully with this nvim + tmux setup.

---

## 🤖 Two-Pane Workflow: Code + pi

A productive setup is to run nvim in one tmux pane and the [pi](https://github.com/earendil-works/pi-coding-agent) coding agent in another, so you can prompt pi for changes and keep editing without leaving the terminal.

### Starting the session

```bash
tmux new -s dev
```

### Creating the two panes

Default prefix is `Ctrl-b`.

```
Ctrl-b %     # split vertically (left = code, right = pi)
Ctrl-b "     # split horizontally (top/bottom)
```

In the left pane: `nvim .`
In the right pane: `pi`

### Moving between panes

This config has **vim-tmux-navigator** enabled, so no prefix needed — the same keys move between Vim splits *and* tmux panes seamlessly:

| Keys              | Action                           |
|-------------------|----------------------------------|
| `Ctrl-h`          | move left (to code pane)         |
| `Ctrl-l`          | move right (to pi pane)          |
| `Ctrl-j` / `Ctrl-k` | move down/up                   |
| `Ctrl-\`          | toggle to last pane              |

So you can fly from a Vim buffer straight into pi with `Ctrl-l`, type a prompt, then `Ctrl-h` back to keep coding.

### Useful extras

- `Ctrl-b z` — zoom current pane fullscreen (toggle).
- `Ctrl-b o` — cycle through panes.
- `Ctrl-b x` — kill current pane.
- `Ctrl-b Space` — cycle layouts.
- `Ctrl-b d` — detach. Reattach with `tmux attach -t dev`.

### Tip: auto-reload edited files in nvim

When pi edits a file open in nvim, reload it with `:e` or set:

```lua
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter", "CursorHold" }, {
  command = "checktime",
})
```

### Optional: one-shot launcher script

Save as `~/.local/bin/dev-session` and `chmod +x`:

```bash
#!/usr/bin/env bash
SESSION="dev"
tmux has-session -t $SESSION 2>/dev/null && exec tmux attach -t $SESSION
tmux new-session -d -s $SESSION -n main
tmux send-keys  -t $SESSION:main 'nvim .' C-m
tmux split-window -h -t $SESSION:main
tmux send-keys  -t $SESSION:main.1 'pi' C-m
tmux select-pane -t $SESSION:main.0
tmux attach -t $SESSION
```

Run `dev-session` from any project directory to spin up the whole layout.

---

## ✅ Applied: pi + nvim live config

This is what's actually wired up in this repo / system (not just suggested):

### 1. Autoread autocmds (in `lua/user/options.lua`)

So buffers refresh automatically when pi (or any tool) edits a file on disk:

```lua
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  pattern = '*',
  command = "if mode() != 'c' | checktime | endif",
  desc = 'Reload buffer if file changed on disk',
})
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  pattern = '*',
  command = "echohl WarningMsg | echo 'File changed on disk. Buffer reloaded.' | echohl None",
})
```

### 2. vim-tmux-navigator plugin (in `lua/user/plugins.lua`)

```lua
{ "christoomey/vim-tmux-navigator", lazy = false },
```

Pairs with the matching bindings already in `~/.tmux.conf` so `Ctrl-h/j/k/l` jumps between Vim splits and tmux panes seamlessly.

### 3. `dev-session` launcher (lives in `~/.local/bin/dev-session`)

Not tracked in this repo — it's a user script. Contents:

```bash
#!/usr/bin/env bash
# Spin up a tmux session with nvim on the left and pi on the right.
# Usage: dev-session [session-name]
#   Defaults session name to the current directory's basename.

SESSION="${1:-$(basename "$PWD")}"

if tmux has-session -t "$SESSION" 2>/dev/null; then
  exec tmux attach -t "$SESSION"
fi

tmux new-session -d -s "$SESSION" -n main -c "$PWD"
tmux send-keys    -t "$SESSION:main" 'nvim .' C-m
tmux split-window -h -t "$SESSION:main" -c "$PWD"
tmux send-keys    -t "$SESSION:main.1" 'pi' C-m
tmux select-pane  -t "$SESSION:main.0"
exec tmux attach  -t "$SESSION"
```

Make it executable: `chmod +x ~/.local/bin/dev-session`.

### 4. PATH for `~/.local/bin`

Added to both `~/.zshrc` and `~/.bashrc`:

```bash
export PATH="$HOME/.local/bin:$PATH"
```

> ⚠️ **Heads up:** running `source ~/.zshrc` from inside a bash shell (e.g. from inside pi, which spawns `/bin/bash -c`) will throw an Oh-My-Zsh error — it's harmless. To pick up new PATH entries, either open a fresh terminal or run `exec zsh` in your interactive shell.

### Usage

```bash
cd <some-project>
dev-session            # creates "<project>" tmux session: nvim left, pi right
# detach: Ctrl-b d   |   reattach: dev-session  (or tmux attach -t <project>)
```
