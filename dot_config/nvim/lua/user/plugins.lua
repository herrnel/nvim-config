-- plugins.lua
-- Bootstrap Lazy.nvim if not installed
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  print("Installing lazy.nvim...")
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
  print("Lazy.nvim installed!")
end
vim.opt.rtp:prepend(lazypath)

-- Plugin specifications
return require("lazy").setup({
  -- Essential plugins
  "nvim-lua/plenary.nvim", -- Utility functions (dependency for many plugins)

  -- Treesitter for syntax highlighting (load early)
  -- NOTE: on the `main` branch, nvim-treesitter does NOT support lazy-loading
  -- and the old `require('nvim-treesitter.configs').setup{}` API is gone.
  -- Configuration lives in lua/user/treesitter.lua using the new API.
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
  },

  -- Language Server Protocol support
  {
    "neovim/nvim-lspconfig", -- Base LSP configurations
    dependencies = {
      -- Server installation manager
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
  },

  -- Autocompletion system
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp", -- LSP source for nvim-cmp
      "hrsh7th/cmp-buffer",   -- Buffer source
      "hrsh7th/cmp-path",     -- Path source
      "L3MON4D3/LuaSnip",     -- Snippet engine
      "saadparwaiz1/cmp_luasnip", -- Snippet source
    },
  },

  -- File explorer
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = { "nvim-tree/nvim-web-devicons" },
  },

  -- Fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { "nvim-lua/plenary.nvim" }
  },

  -- Key binding helper
  {
    "folke/which-key.nvim",
  },

  -- Theme (load last after all functionality is configured)
  { 
    "catppuccin/nvim", 
    name = "catppuccin",
    priority = 1000, -- Load last
  },

  -- Rose Pine theme (seafoam-ish via the 'moon' variant)
  {
    "rose-pine/neovim",
    name = "rose-pine",
    priority = 1000,
  },

  -- Vague theme
  {
    "vague2k/vague.nvim",
    name = "vague",
    priority = 1000,
  },
  {
     "christoomey/vim-tmux-navigator", lazy = false 
  },

  -- Pretty in-buffer markdown rendering
  {
    "MeanderingProgrammer/render-markdown.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons",
    },
    ft = { "markdown" },
  },

  -- Browser-based live markdown preview (real HTML render)
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreview", "MarkdownPreviewStop", "MarkdownPreviewToggle" },
    ft = { "markdown" },
    build = function() vim.fn["mkdp#util#install"]() end,
  },

  -- Auto-close brackets / quotes and place the cursor between them
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    dependencies = { "hrsh7th/nvim-cmp" },
    config = function()
      local npairs = require("nvim-autopairs")
      npairs.setup({
        check_ts = true,                 -- use treesitter to avoid pairing in strings/comments
        enable_check_bracket_line = true,-- don't add a pair if next char is a closing one
        fast_wrap = {                    -- <M-e> in insert mode wraps the next text in pairs
          map = "<M-e>",
          chars = { "{", "[", "(", '"', "'" },
          end_key = "$",
          keys = "qwertyuiopzxcvbnmasdfghjkl",
          check_comma = true,
          highlight = "Search",
          highlight_grey = "Comment",
        },
      })

      -- Make autopairs cooperate with nvim-cmp: when you accept a function
      -- completion, automatically insert the `()`.
      local has_cmp, cmp = pcall(require, "cmp")
      if has_cmp then
        local cmp_autopairs = require("nvim-autopairs.completion.cmp")
        cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())
      end
    end,
  },


  -- For displaying inline diagnostic messages with customizable styles and icons.
  {
      "rachartier/tiny-inline-diagnostic.nvim",
      event = "VeryLazy",
      priority = 1000,
      config = function()
          require("user.tiny-inline-diagnostic") -- runs the customized setup({...})
          vim.diagnostic.config({ virtual_text = false }) -- Disable Neovim's default virtual text diagnostics
      end,
  },

})

