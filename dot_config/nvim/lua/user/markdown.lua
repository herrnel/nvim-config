-- markdown.lua
-- Two-layer markdown setup:
--   1. render-markdown.nvim — pretty in-buffer rendering (headings, code, checkboxes)
--   2. markdown-preview.nvim — real HTML preview in the browser

------------------------------------------------------------
-- 1. render-markdown.nvim (in-buffer)
------------------------------------------------------------
local ok, render_markdown = pcall(require, 'render-markdown')
if ok then
  render_markdown.setup({
    enabled = true,
    render_modes = { 'n', 'c', 't' }, -- raw syntax visible in insert/visual

    heading = {
      sign = true,
      icons = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
      width = 'block',                 -- background bar spans only the heading text
      left_pad = 0,
      right_pad = 4,
      -- Use render-markdown's built-in highlight groups for the bar + text.
      backgrounds = {
        'RenderMarkdownH1Bg', 'RenderMarkdownH2Bg', 'RenderMarkdownH3Bg',
        'RenderMarkdownH4Bg', 'RenderMarkdownH5Bg', 'RenderMarkdownH6Bg',
      },
      foregrounds = {
        'RenderMarkdownH1', 'RenderMarkdownH2', 'RenderMarkdownH3',
        'RenderMarkdownH4', 'RenderMarkdownH5', 'RenderMarkdownH6',
      },
    },

    code = {
      sign = false,
      width = 'block',
      right_pad = 1,
    },

    checkbox = {
      unchecked = { icon = '󰄱 ' },
      checked   = { icon = '󰱒 ' },
    },
  })

  -- Make headings bold + tinted backgrounds so they read "bigger" visually.
  -- Reapply on colorscheme change so vague (or any fallback) doesn't clobber them.
  local function tint_headings()
    -- Foregrounds: bold heading text
    vim.api.nvim_set_hl(0, 'RenderMarkdownH1', { fg = '#e0a363', bold = true })
    vim.api.nvim_set_hl(0, 'RenderMarkdownH2', { fg = '#c48282', bold = true })
    vim.api.nvim_set_hl(0, 'RenderMarkdownH3', { fg = '#bb9dbd', bold = true })
    vim.api.nvim_set_hl(0, 'RenderMarkdownH4', { fg = '#9bb4bc', bold = true })
    vim.api.nvim_set_hl(0, 'RenderMarkdownH5', { fg = '#6e94b2', bold = true })
    vim.api.nvim_set_hl(0, 'RenderMarkdownH6', { fg = '#7e98e8', bold = true })
    -- Backgrounds: subtle bars (darker tint of the matching fg)
    vim.api.nvim_set_hl(0, 'RenderMarkdownH1Bg', { bg = '#3a2a1f' })
    vim.api.nvim_set_hl(0, 'RenderMarkdownH2Bg', { bg = '#3a2424' })
    vim.api.nvim_set_hl(0, 'RenderMarkdownH3Bg', { bg = '#332838' })
    vim.api.nvim_set_hl(0, 'RenderMarkdownH4Bg', { bg = '#243033' })
    vim.api.nvim_set_hl(0, 'RenderMarkdownH5Bg', { bg = '#1f2a38' })
    vim.api.nvim_set_hl(0, 'RenderMarkdownH6Bg', { bg = '#222a3d' })
  end
  tint_headings()
  vim.api.nvim_create_autocmd('ColorScheme', {
    desc = 'Re-apply render-markdown heading colors after :colorscheme',
    callback = tint_headings,
  })

  -- <leader>mr toggles in-buffer rendering
  vim.keymap.set('n', '<leader>mr', '<cmd>RenderMarkdown toggle<cr>',
    { desc = 'Markdown: toggle in-buffer rendering' })
end

------------------------------------------------------------
-- 2. markdown-preview.nvim (browser preview)
------------------------------------------------------------
-- Defaults are fine; tweak a couple of UX bits.
vim.g.mkdp_auto_start  = 0          -- don't auto-open on file open
vim.g.mkdp_auto_close  = 1          -- close preview tab when buffer closes
vim.g.mkdp_theme       = 'dark'     -- 'dark' | 'light'
vim.g.mkdp_browser     = ''         -- '' = system default; e.g. 'firefox'

-- <leader>mp to toggle the browser preview
vim.keymap.set('n', '<leader>mp', '<cmd>MarkdownPreviewToggle<cr>',
  { desc = 'Markdown: toggle browser preview' })
