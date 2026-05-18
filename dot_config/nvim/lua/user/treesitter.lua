-- treesitter.lua
--
-- Configuration for nvim-treesitter's `main` branch (the rewrite).
-- The old `require('nvim-treesitter.configs').setup{}` API is GONE.
-- Features that used to be toggled by keys in that table are now:
--   * highlight                → vim.treesitter.start() in a FileType autocmd
--   * indent                   → vim.bo.indentexpr in a FileType autocmd
--   * folds                    → vim.wo foldexpr/foldmethod in a FileType autocmd
--   * ensure_installed         → require('nvim-treesitter').install({...})
--   * auto_install             → not supported; install explicitly
--   * incremental_selection    → removed; we re-implement a minimal version below
--
-- Docs: ~/.local/share/nvim/lazy/nvim-treesitter/README.md

local ok, nts = pcall(require, 'nvim-treesitter')
if not ok then
  vim.notify('nvim-treesitter not available', vim.log.levels.WARN)
  return
end

-- Optional: pin install dir to the lazy/site default. Leaving the default
-- means parsers land in stdpath('data')/site/parser/.
nts.setup {}

------------------------------------------------------------------------------
-- 1. Parsers to install (replaces old `ensure_installed`)
------------------------------------------------------------------------------
-- `install` is async and idempotent; safe to call on every startup.
nts.install {
  'lua', 'vim', 'vimdoc', 'query',
  'javascript', 'typescript', 'tsx',
  'python', 'rust', 'go',
  'html', 'css', 'json', 'yaml', 'toml',
  'markdown', 'markdown_inline',
  'bash',
}

------------------------------------------------------------------------------
-- 2. Enable highlight / indent / folds per-filetype
------------------------------------------------------------------------------
-- Filetypes that have a parser available + working queries.
-- Add to this list as you install more parsers.
local enabled_filetypes = {
  'lua', 'vim', 'help', 'query',
  'javascript', 'typescript', 'typescriptreact', 'javascriptreact',
  'python', 'rust', 'go',
  'html', 'css', 'json', 'yaml', 'toml',
  'markdown',
  'sh', 'bash',
}

vim.api.nvim_create_autocmd('FileType', {
  group = vim.api.nvim_create_augroup('user_treesitter', { clear = true }),
  pattern = enabled_filetypes,
  callback = function(args)
    -- Highlighting (provided by core Neovim)
    pcall(vim.treesitter.start, args.buf)

    -- Indentation (experimental, provided by nvim-treesitter main)
    vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"

    -- Folding (provided by core). Comment these out if you dislike auto-folds.
    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.wo.foldmethod = 'expr'
    vim.wo.foldenable = false -- start with folds open
  end,
})

------------------------------------------------------------------------------
-- 3. Minimal incremental selection (replaces removed module)
--    <CR> = grow selection to parent node     <BS> = shrink to child
------------------------------------------------------------------------------
local sel_stack_by_buf = {}

local function start_or_grow()
  local buf = vim.api.nvim_get_current_buf()
  local stack = sel_stack_by_buf[buf]

  local node
  if not stack or #stack == 0 then
    node = vim.treesitter.get_node()
    if not node then return end
    stack = { node }
  else
    node = stack[#stack]:parent()
    if not node then return end
    table.insert(stack, node)
  end
  sel_stack_by_buf[buf] = stack

  local srow, scol, erow, ecol = node:range()
  vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
  vim.cmd('normal! v')
  vim.api.nvim_win_set_cursor(0, { erow + 1, math.max(ecol - 1, 0) })
end

local function shrink()
  local buf = vim.api.nvim_get_current_buf()
  local stack = sel_stack_by_buf[buf]
  if not stack or #stack <= 1 then return end
  table.remove(stack)
  local node = stack[#stack]
  local srow, scol, erow, ecol = node:range()
  vim.api.nvim_win_set_cursor(0, { srow + 1, scol })
  vim.cmd('normal! v')
  vim.api.nvim_win_set_cursor(0, { erow + 1, math.max(ecol - 1, 0) })
end

-- Reset the per-buffer stack when leaving visual mode.
vim.api.nvim_create_autocmd('ModeChanged', {
  pattern = 'v:*',
  callback = function()
    sel_stack_by_buf[vim.api.nvim_get_current_buf()] = nil
  end,
})

vim.keymap.set('n', '<CR>', start_or_grow, { desc = 'TS: init/grow selection' })
vim.keymap.set('x', '<CR>', start_or_grow, { desc = 'TS: grow selection' })
vim.keymap.set('x', '<BS>', shrink,        { desc = 'TS: shrink selection' })
