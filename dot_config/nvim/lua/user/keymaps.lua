
-- [[ Set up keymaps ]] See `:h vim.keymap.set()`, `:h mapping`, `:h keycodes`

-- Use <Esc> to exit terminal mode
vim.keymap.set('t', '<Esc>', '<C-\\><C-n>')

-- Map <A-j>, <A-k>, <A-h>, <A-l> to navigate between windows in any modes
vim.keymap.set({ 't', 'i' }, '<A-h>', '<C-\\><C-n><C-w>h')
vim.keymap.set({ 't', 'i' }, '<A-j>', '<C-\\><C-n><C-w>j')
vim.keymap.set({ 't', 'i' }, '<A-k>', '<C-\\><C-n><C-w>k')
vim.keymap.set({ 't', 'i' }, '<A-l>', '<C-\\><C-n><C-w>l')
vim.keymap.set({ 'n' }, '<A-h>', '<C-w>h')
vim.keymap.set({ 'n' }, '<A-j>', '<C-w>j')
vim.keymap.set({ 'n' }, '<A-k>', '<C-w>k')
vim.keymap.set({ 'n' }, '<A-l>', '<C-w>l')

-- [[ Comment toggling — VS Code-style Ctrl-/ ]]
-- Most terminals send <C-_> when you press Ctrl-/ (it's an ASCII quirk),
-- so bind both for safety. Uses Neovim's built-in `gc` operator (0.10+).
--   - Normal mode: toggle comment on the current line
--   - Visual mode: toggle comment on the selection (and stay in visual)
for _, key in ipairs({ '<C-_>', '<C-/>' }) do
  vim.keymap.set('n', key, 'gcc',
    { remap = true, desc = 'Toggle comment (current line)' })
  vim.keymap.set('x', key, 'gc',
    { remap = true, desc = 'Toggle comment (selection)' })
  -- Also from insert mode, in case muscle memory hits it there too:
  vim.keymap.set('i', key, '<Esc>gcca',
    { remap = true, desc = 'Toggle comment (current line)' })
end

-- [[ Telescope keymaps ]]
local ok, builtin = pcall(require, 'telescope.builtin')
if ok then
  vim.keymap.set('n', '<leader>ff', builtin.find_files,            { desc = 'Find files' })
  vim.keymap.set('n', '<leader>fg', builtin.live_grep,             { desc = 'Grep project' })
  vim.keymap.set('n', '<leader>fb', builtin.buffers,               { desc = 'Open buffers' })
  vim.keymap.set('n', '<leader>fh', builtin.help_tags,             { desc = 'Help tags' })
  vim.keymap.set('n', '<leader>fr', builtin.resume,                { desc = 'Resume last picker' })
  vim.keymap.set('n', '<leader>fs', builtin.lsp_document_symbols,  { desc = 'Symbols (file)' })
  vim.keymap.set('n', '<leader>fS', builtin.lsp_dynamic_workspace_symbols, { desc = 'Symbols (project)' })

  -- LSP navigation via Telescope (nicer UI than the defaults; also a reliable
  -- fallback when buffer-local LSP keymaps haven't attached yet).
  vim.keymap.set('n', 'gd', builtin.lsp_definitions,      { desc = 'Go to definition' })
  vim.keymap.set('n', 'gi', builtin.lsp_implementations,  { desc = 'Go to implementation' })
  vim.keymap.set('n', 'gr', builtin.lsp_references,       { desc = 'References' })
  vim.keymap.set('n', 'gt', builtin.lsp_type_definitions, { desc = 'Type definition' })
end
