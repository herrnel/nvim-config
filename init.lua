
---
--- Please look at this page to understand this setup https://dev.to/mochafreddo/configuring-neovim-with-initlua-a-comprehensive-guide-2a7i
---

-- Initialize core settings first
require('user.options')
require('user.keymaps')

-- Load plugin manage
require('user.plugins')

-- Set up plugins with dependencies
require('user.treesitter') -- Set up before LSP for better highlighting
require('user.lsp')  -- Depends on language servers being available
require('user.completion') -- Depends on LSP configuration
require('user.telescope') -- Often integrates with LSP

-- Optional UI / helpers
require('user.whichkey')
require('user.explorer')

-- Configure UI components last
require('user.theme')


