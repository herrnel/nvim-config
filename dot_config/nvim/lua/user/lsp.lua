-- lsp.lua
-- Install Mason first for managing servers
require("mason").setup({
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
})

-- Connect Mason with lspconfig
require("mason-lspconfig").setup({
  -- Automatically install these servers
  ensure_installed = {
    "lua_ls",      -- Lua
    "pyright",     -- Python
    "ts_ls",       -- TypeScript/JavaScript
    "rust_analyzer", -- Rust
    -- "gopls",       -- Go (install Go separately, or `apt install gopls`) -- "clangd",      -- C/C++ (no aarch64 build in Mason; using system /usr/bin/clangd)
  },
  automatic_installation = true,
  -- Let mason-lspconfig auto-enable installed servers via vim.lsp.enable().
  -- Per-server configuration is handled below via vim.lsp.config().
  automatic_enable = true,
})

-- Set up LSP capabilities (used by completion)
local capabilities = vim.lsp.protocol.make_client_capabilities()
-- Check if nvim-cmp is available to enhance capabilities
local has_cmp, cmp_lsp = pcall(require, 'cmp_nvim_lsp')
if has_cmp then
  capabilities = cmp_lsp.default_capabilities(capabilities)
end

-- Function to set up all installed LSP servers
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'

  -- Key mappings (buffer-local). Navigation keys (gd, gi, gr, gt) are set
  -- globally via Telescope in keymaps.lua so they work consistently.
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<leader>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<leader>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', '<leader>lf', function() vim.lsp.buf.format { async = true } end, bufopts)

  -- Log a message when a server attaches
  print(string.format("LSP server '%s' attached to this buffer", client.name))
end

-- Per-server overrides
local server_configs = {
  lua_ls = {
    settings = {
      Lua = {
        runtime = { version = 'LuaJIT' },
        diagnostics = { globals = { 'vim' } },
        workspace = {
          library = vim.api.nvim_get_runtime_file("", true),
          checkThirdParty = false,
        },
        telemetry = { enable = false },
      },
    },
  },
}

-- Apply shared defaults to every LSP server via the new vim.lsp.config API
-- (Neovim 0.11+). See :help lspconfig-nvim-0.11.
vim.lsp.config('*', {
  on_attach = on_attach,
  capabilities = capabilities,
})

-- Apply per-server overrides.
for server_name, opts in pairs(server_configs) do
  vim.lsp.config(server_name, opts)
end

-- Configure diagnostic display
vim.diagnostic.config({
  virtual_text = false,
  float = {
    source = true,
    border = "rounded",
  },
  signs = true,
  underline = true,
  update_in_insert = false,
  severity_sort = true,
})

-- Change diagnostic symbols in the sign column
local signs = { Error = " ", Warn = " ", Hint = " ", Info = " " }
for type, icon in pairs(signs) do
  local hl = "DiagnosticSign" .. type
  vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end
