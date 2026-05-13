# Dotfiles — Neovim + Tmux (managed with chezmoi)

This single repo contains **all** your tracked configs (nvim, tmux, future
shells, etc.) and is deployed with [chezmoi](https://www.chezmoi.io/).

> Renamed in spirit from `nvim-config` → dotfiles. The GitHub repo URL can
> be renamed in the GitHub UI when convenient; chezmoi will follow.

## 📁 Repo layout (chezmoi conventions)

```
~/.local/share/chezmoi/         ← chezmoi's source dir = this git repo
├── dot_tmux.conf               → ~/.tmux.conf
├── dot_config/
│   └── nvim/                   → ~/.config/nvim/
│       ├── init.lua
│       ├── lazy-lock.json
│       ├── nvim-pack-lock.json
│       └── lua/user/
│           ├── options.lua
│           ├── keymaps.lua
│           ├── plugins.lua
│           ├── treesitter.lua
│           ├── lsp.lua
│           ├── completion.lua
│           ├── telescope.lua
│           ├── whichkey.lua
│           ├── explorer.lua
│           └── theme.lua
├── SETUP_NOTES.md              (this file — not deployed, pure docs)
└── .gitignore
```

**Naming rules cheat-sheet** (chezmoi):
- `dot_<name>` → `~/.<name>` (so `dot_tmux.conf` becomes `~/.tmux.conf`)
- Subdirs follow the same pattern recursively
- Files **without** a recognized prefix at the source root are ignored — that's
  why `SETUP_NOTES.md` and `README.md` stay at the source root and are not
  deployed anywhere.

## ✨ What's wired up

### Neovim (unchanged from before)
- Leader = `<Space>`. Catppuccin Mocha theme.
- LSP via Mason: Lua, Python, TS/JS, Rust, Go, C/C++.
- Telescope (`<leader>f…`), nvim-tree (`<leader>e`), which-key, nvim-cmp,
  Treesitter, vim-tmux-navigator.
- Autoread autocmd reloads buffers when external tools (e.g. `pi`) modify files.

### Tmux
- True color + focus events + 10ms escape time.
- Mouse on, 50k scrollback, vi copy-mode, base index 1.
- `Ctrl-h/j/k/l` jumps seamlessly between nvim splits and tmux panes
  (matches the `vim-tmux-navigator` plugin).
- Custom orange/white status theme.
- tpm + `tmux-sensible`.

### `dev-session` launcher (`~/.local/bin/dev-session`)
Not deployed by chezmoi (it's a user script, not a config). Contents:

```bash
#!/usr/bin/env bash
# Spin up a tmux session: nvim left, pi right.
# Usage: dev-session [session-name]   (default: basename of $PWD)
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

`chmod +x ~/.local/bin/dev-session`. Requires `~/.local/bin` on `PATH` (already
in `~/.zshrc` and `~/.bashrc`).

---

## 🚀 Daily workflow

### Editing configs

Two equivalent patterns — pick your favorite:

**A. Edit via chezmoi (recommended)** — opens the *source* file, auto-applies on save:

```bash
chezmoi edit ~/.tmux.conf
chezmoi edit ~/.config/nvim/init.lua
```

**B. Edit deployed file in place, then re-add:**

```bash
nvim ~/.config/nvim/init.lua          # edit normally
chezmoi re-add                        # pull changes back into the source repo
```

Handy alias to drop in `~/.zshrc`:

```bash
alias ce='chezmoi edit'
alias cs='chezmoi status'
alias ca='chezmoi apply -v'
alias cd-cm='cd $(chezmoi source-path)'
```

### Committing & pushing

```bash
chezmoi cd                            # jumps you into the source repo
git add -A && git commit -m "tweak: ..."
git push
exit                                  # back to where you were
```

### On a new machine

```bash
# Prereqs
sudo apt-get install -y git tmux curl

# 1. Install chezmoi
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin
export PATH="$HOME/.local/bin:$PATH"

# 2. Pull dotfiles + deploy
chezmoi init https://github.com/herrnel/nvim-config.git   # (or new dotfiles URL)
chezmoi apply -v

# 3. Tmux plugin manager + plugins
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
~/.tmux/plugins/tpm/bin/install_plugins

# 4. Neovim plugins (lazy.nvim bootstraps itself, then restore pinned versions)
nvim --headless "+Lazy! restore" +qa

# 5. dev-session launcher
mkdir -p ~/.local/bin
# (paste the script above into ~/.local/bin/dev-session, then:)
chmod +x ~/.local/bin/dev-session
```

### Pulling changes from another machine

```bash
chezmoi update            # = git pull + chezmoi apply
```

### Diff / dry-run before applying

```bash
chezmoi diff              # show what would change
chezmoi apply --dry-run -v
```

---

## 🪟 Using tmux + the `dev-session` workflow

```bash
cd <some-project>
dev-session               # creates tmux session "<project>": nvim left, pi right
```

Inside:

| Keys                | Action |
|---------------------|--------|
| `Ctrl-h/j/k/l`      | Move across nvim splits *and* tmux panes uniformly |
| `Ctrl-b z`          | Zoom current pane (toggle) |
| `Ctrl-b d`          | Detach (re-attach later with `dev-session` or `tmux attach -t <name>`) |
| `Ctrl-b %` / `"`    | New vertical / horizontal split |
| `Ctrl-b [`          | Enter copy mode (vi keys, `q` to exit) |
| `Ctrl-b I`          | Install tmux plugins (after editing tpm `@plugin` lines) |
| `Ctrl-b r`          | (Not bound by default) — reload conf with `tmux source-file ~/.tmux.conf` |

---

## 🤖 Two-pane workflow: nvim + pi

Already covered by `dev-session`. The autoread autocmd in
`dot_config/nvim/lua/user/options.lua` ensures nvim reloads any file that pi
edits on disk:

```lua
vim.opt.autoread = true
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  pattern = '*',
  command = "if mode() != 'c' | checktime | endif",
})
vim.api.nvim_create_autocmd('FileChangedShellPost', {
  pattern = '*',
  command = "echohl WarningMsg | echo 'File changed on disk. Buffer reloaded.' | echohl None",
})
```

> **Heads up:** running `source ~/.zshrc` from a bash subshell (e.g. inside pi,
> which spawns `/bin/bash -c`) throws an Oh-My-Zsh error — harmless. To pick up
> new PATH entries open a fresh terminal or `exec zsh`.

---

## 🌍 Cross-OS notes

chezmoi works natively on **Linux, macOS, WSL, and Windows** (single Go
binary). For per-machine differences use templating (`*.tmpl` files,
`.chezmoi.toml.tmpl` config), e.g.:

```yaml
# dot_gitconfig.tmpl
[user]
  email = {{ if eq .chezmoi.os "darwin" }}me@personal.com{{ else }}me@work.com{{ end }}
```

Run `chezmoi data` to see all available variables (`.chezmoi.os`,
`.chezmoi.hostname`, `.chezmoi.username`, etc.).

### Adding more configs later

```bash
chezmoi add ~/.gitconfig          # imports it into the source repo (becomes dot_gitconfig)
chezmoi add ~/.config/ghostty/config
chezmoi cd && git add -A && git commit -m "Add gitconfig + ghostty"
git push
```

---

## 🔤 Nerd Font setup (icons in nvim/tmux)

Icon glyphs (folder/file/git/lang icons in Telescope, nvim-tree, lualine,
etc.) are rendered by **your terminal's font** — not by anything on the Linux
side. So fixing missing/`?` icons means installing a Nerd Font in the
terminal that's actually drawing pixels (on WSL = the Windows-side terminal).

### Quick test

Run in any shell:

```bash
printf '\uf07b folder \uf15b file \ue7c5 lua \uf1c9 movie \uf09b github  branch\n'
```

If those render as recognizable icons → you're good. If you see `?`, boxes,
or blank spots → install a Nerd Font and select it in your terminal.

### Recommended font

**JetBrainsMono Nerd Font** — clean, monospaced, full glyph coverage,
works in tmux. Alternatives: FiraCode Nerd Font, Hack Nerd Font, MesloLGS NF.

### Linux side (already installed on this machine)

```bash
mkdir -p ~/.local/share/fonts/JetBrainsMonoNerdFont
curl -fsSLo /tmp/JBM.zip \
  https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
unzip -oq /tmp/JBM.zip -d ~/.local/share/fonts/JetBrainsMonoNerdFont/
fc-cache -f ~/.local/share/fonts
fc-list | grep -i 'jetbrainsmono nerd'   # verify
```

This is mostly a no-op for WSL terminals (Windows draws the glyphs), but it
helps if you ever run a Linux-native GUI terminal or do remote rendering.

### Windows side (the one that actually matters for WSL)

#### Option 1 — winget (cleanest)

In **PowerShell**:

```powershell
winget install --id=DEVCOM.JetBrainsMonoNerdFont -e
# or browse:  winget search nerd-fonts
```

#### Option 2 — Scoop

```powershell
scoop bucket add nerd-fonts
scoop install nerd-fonts/JetBrainsMono-NF
```

#### Option 3 — Manual

1. Download `JetBrainsMono.zip` from <https://www.nerdfonts.com/font-downloads>.
2. Extract, select all `.ttf` files → right-click → **Install for all users**.

### Select the font in your terminal

**Windows Terminal** — `Settings` → your WSL profile → `Appearance` →
`Font face` = `JetBrainsMono Nerd Font` (or edit `settings.json`):

```json
"profiles": {
  "defaults": { "font": { "face": "JetBrainsMono Nerd Font", "size": 12 } }
}
```

**WezTerm** — `~/.wezterm.lua`:

```lua
config.font = wezterm.font('JetBrainsMono Nerd Font')
config.font_size = 12
```

**Ghostty** (Linux/macOS) — `~/.config/ghostty/config`:

```
font-family = JetBrainsMono Nerd Font
font-size = 12
```

**Alacritty** — `~/.config/alacritty/alacritty.toml`:

```toml
[font.normal]
family = "JetBrainsMono Nerd Font"
```

### After installing

1. Restart the terminal (Windows Terminal needs a full restart to pick up
   newly installed system fonts).
2. Re-open tmux / nvim — Telescope, nvim-tree, and devicons will now show
   actual glyphs instead of `?`.
3. If still broken inside tmux specifically, check `echo $TERM` (should be
   `tmux-256color`) — already set in your `dot_tmux.conf`.

---

## 🗑️ History

This repo was originally `nvim-config` and managed only `~/.config/nvim/`.
On 2026-05-13 it was restructured into chezmoi layout to also manage
`~/.tmux.conf` (previously a separate `~/dotfiles/` stow repo, now removed).
Git history is preserved through `git mv`.
