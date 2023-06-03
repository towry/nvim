--- configurations for the editor UI.
--- aspect:
---   - lsp diagnostic signs.
---   - lsp virtual text display.
---   - highlight for plugins or builtins.

local M = {}

M.theme = {
  colorscheme = 'everforest', -- colorscheme name.
  background = 'auto', -- auto, dark, light.
  contrast = 'soft', -- soft, medium, hard.
}

--- configuration for theme everforest
M.theme_everforest = {
  --- @type number
  better_performance = 0, -- 0, 1.
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
