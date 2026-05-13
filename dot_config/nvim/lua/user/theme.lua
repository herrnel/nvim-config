-- theme.lua

-- Configure Rose Pine (must be set up before :colorscheme)
local has_rose_pine, rose_pine = pcall(require, "rose-pine")
if has_rose_pine then
  local setup_ok, _ = pcall(rose_pine.setup, {
    variant = "main",       -- "main" | "moon" | "dawn" | "auto"
    dark_variant = "main",
    disable_background = false,
    styles = {
      bold = true,
      italic = true,
      transparency = false,
    },
  })
  if not setup_ok then
    print("Error setting up rose-pine theme. Using default configuration.")
  end
end

-- Try rose-pine first, fall back to catppuccin, then default
local function set_colorscheme(name)
  return pcall(vim.cmd, "colorscheme " .. name)
end

if not set_colorscheme("rose-pine") then
  print("Warning: rose-pine not found. Trying catppuccin...")
  if not set_colorscheme("catppuccin") then
    print("Warning: no preferred theme found. Falling back to default.")
    return
  end
end

print("Theme initialized!")
