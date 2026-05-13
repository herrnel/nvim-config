-- whichkey.lua (which-key.nvim v3 API)
local has_which_key, which_key = pcall(require, "which-key")
if not has_which_key then
  print("Warning: which-key not found. Key binding help won't be available.")
  return
end

-- v3 uses a flat opts table; the v2 `window`/`layout`/`plugins.presets` tables
-- are no longer valid here.
local setup_ok = pcall(which_key.setup, {
  preset = "modern",
  win = { border = "rounded" },
})

if not setup_ok then
  print("Error setting up which-key. Key binding help won't work correctly.")
  return
end

-- v3 mapping spec: a flat list of entries. `register{}` was removed.
local add_ok, err = pcall(which_key.add, {
  { "<leader>f",  group = "File" },
  { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "Find File" },
  { "<leader>fr", "<cmd>Telescope oldfiles<cr>",    desc = "Recent Files" },
  { "<leader>fg", "<cmd>Telescope live_grep<cr>",   desc = "Live Grep" },
  { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "Buffers" },
  { "<leader>fn", "<cmd>enew<cr>",                  desc = "New File" },

  { "<leader>e",  "<cmd>NvimTreeToggle<cr>",        desc = "Explorer" },

  { "<leader>l",  group = "LSP" },
  { "<leader>ld", "<cmd>Telescope lsp_definitions<cr>", desc = "Definitions" },
  { "<leader>lr", "<cmd>Telescope lsp_references<cr>",  desc = "References" },
  { "<leader>la", function() vim.lsp.buf.code_action() end, desc = "Code Action" },
  { "<leader>lf", function() vim.lsp.buf.format() end,      desc = "Format" },
  { "<leader>lh", function() vim.lsp.buf.hover() end,       desc = "Hover" },
  { "<leader>lR", function() vim.lsp.buf.rename() end,      desc = "Rename" },

  { "<leader>b",  group = "Buffer" },
  { "<leader>bn", "<cmd>bnext<cr>",     desc = "Next Buffer" },
  { "<leader>bp", "<cmd>bprevious<cr>", desc = "Previous Buffer" },
  { "<leader>bd", "<cmd>bdelete<cr>",   desc = "Delete Buffer" },
})

if not add_ok then
  print("Error registering which-key bindings: " .. tostring(err))
  return
end

print("Key binding help initialized!")
