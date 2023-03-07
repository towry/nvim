--- configurations for the editor UI.
--- aspect:
---   - lsp diagnostic signs.
---   - lsp virtual text display.
---   - highlight for plugins or builtins.

local M = {}

M.theme = {
  colorscheme = 'everforest', -- colorscheme name.
  background = 'auto', -- auto, dark, light.
  contrast = 'medium', -- soft, medium, hard.
}

--- configuration for theme everforest
M.theme_everforest = {
  --- @type number
  better_performance = 1, -- 1, 2, 3.
  italic = true,
}

--- configurations for lsp diagnostic.
M.diagnostic = {
  --- @see vim.diagnostic.config
  --- @type table|boolean
  virtual_text = false, -- disable virtual text for diagnostic.
}

M.float = {
  border = 'rounded',
}

return M
