-- explorer.lua
-- Check if nvim-tree is available
local has_tree, nvim_tree = pcall(require, "nvim-tree")
if not has_tree then
  print("Warning: nvim-tree not found. File explorer won't be available.")
  return
end

-- Set up nvim-tree with error handling
local setup_ok, _ = pcall(nvim_tree.setup, {
  sort_by = "case_sensitive",
  view = {
    width = 30,
  },
  renderer = {
    group_empty = true,
    icons = {
      show = {
        git = true,
        folder = true,
        file = true,
        folder_arrow = true,
      },
    },
  },
  filters = {
    dotfiles = false,
  },
  git = {
    enable = true,
    ignore = false,
  },
  actions = {
    open_file = {
      quit_on_open = false,
      resize_window = true,
    },
  },
})

if not setup_ok then
  print("Error setting up nvim-tree. Some features might not work correctly.")
  return
end

-- Recommended mappings
vim.keymap.set('n', '<leader>e', '<cmd>NvimTreeToggle<CR>', { desc = "Toggle file explorer" })
vim.keymap.set('n', '<leader>fe', '<cmd>NvimTreeFocus<CR>', { desc = "Focus file explorer" })

print("File explorer initialized!")
