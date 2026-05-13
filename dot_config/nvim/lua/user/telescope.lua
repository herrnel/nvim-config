-- telescope.lua
-- Check if telescope is available
local has_telescope, telescope = pcall(require, "telescope")
if not has_telescope then
  print("Warning: telescope not found. Fuzzy finding won't be available.")
  return
end

-- Set up telescope with error handling
local setup_ok, _ = pcall(telescope.setup, {
  defaults = {
    prompt_prefix = "🔍 ",
    selection_caret = "❯ ",
    path_display = { "truncate" },
    layout_config = {
      horizontal = {
        preview_width = 0.55,
        results_width = 0.8,
      },
      width = 0.87,
      height = 0.80,
      preview_cutoff = 120,
    },
    file_ignore_patterns = {
      "node_modules/",
      ".git/",
      ".DS_Store"
    },
  },
  extensions = {
    -- Configure any extensions here
  }
})

if not setup_ok then
  print("Error setting up telescope. Some features might not work correctly.")
  return
end

-- Load telescope extensions if available
pcall(function() require('telescope').load_extension('fzf') end)

-- Useful Telescope mappings with error handling
local builtin_ok, builtin = pcall(require, 'telescope.builtin')
if builtin_ok then
  vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = "Find files" })
  vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = "Live grep" })
  vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = "Buffers" })
  vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = "Help tags" })
  -- LSP-related searches
  vim.keymap.set('n', '<leader>fd', builtin.lsp_definitions, { desc = "Find definitions" })
  vim.keymap.set('n', '<leader>fr', builtin.lsp_references, { desc = "Find references" })
end

print("Fuzzy finder initialized!")
