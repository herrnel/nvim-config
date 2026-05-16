-- theme.lua

-- Configure Vague (must be set up before :colorscheme)
local has_vague, vague = pcall(require, "vague")
if has_vague then
  local setup_ok, _ = pcall(vague.setup, {
    transparent = false,
    bold = true,
    italic = true,
    -- Optionally override palette colors here, e.g.:
    -- colors = { bg = "#141415", comment = "#606079" },
    -- Use on_highlights for per-group tweaks (replaces the old `style` table):
    on_highlights = function(hl, c)
      hl.Comment        = { fg = c.comment, italic = true }
      hl.Boolean        = { fg = c.constant, bold = true }
      hl.Constant       = { fg = c.constant, bold = true }
      hl.Type           = { fg = c.type, bold = true }
      hl["@keyword.return"] = { fg = c.keyword, italic = true }
      hl.Title          = { bold = true }
      hl.Error          = { fg = c.error, bold = true }
    end,
  })
  if not setup_ok then
    print("Error setting up vague theme. Using default configuration.")
  end
end

-- Try vague first, fall back to rose-pine, then catppuccin
local function set_colorscheme(name)
  return pcall(vim.cmd, "colorscheme " .. name)
end

if not set_colorscheme("vague") then
  print("Warning: vague not found. Trying rose-pine...")
  if not set_colorscheme("rose-pine") then
    print("Warning: rose-pine not found. Trying catppuccin...")
    if not set_colorscheme("catppuccin") then
      print("Warning: no preferred theme found. Falling back to default.")
      return
    end
  end
end

print("Theme initialized!")
