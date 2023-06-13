local plug = require('libs.runtime.pack').plug

local function override(colors)
  local default = colors.palette
  local theme = colors.theme

  local background = default.sumiInk1
  local darker = false
  if darker then
    if type(darker) == "string" then
      background = vim.cfg.ui.darker_background
    else
      background = "#0d1117"
    end
  end

  local overrides = {
    CmpDocumentation = { link = "Pmenu" },
    CmpItemKindField = { link = "@field" },
    CmpItemKindKeyword = { link = "@keyword.return" },
    CmpItemKindProperty = { link = "@property" },
    DiagnosticSignError = { bg = "#2A1C23" },
    DiagnosticSignHint = { bg = "#1C1E2A" },
    DiagnosticSignInfo = { bg = "#262729" },
    DiagnosticSignWarn = { bg = "#2F261A" },
    GitSignsAdd = { bg = background },
    GitSignsChange = { bg = background },
    GitSignsDelete = { bg = background },
    HighLightLineMatches = { bg = default.winterYellow },
    LeapBackdrop = { fg = default.dragonBlue },
    LeapMatch = { fg = default.fujiWhite, bold = true, nocombine = true },
    LeapLabelPrimary = {
      fg = default.sumiInk4,
      bg = default.roninYellow,
      bold = true,
      nocombine = true,
    },
    LeapLabelSecondary = {
      fg = default.springBlue,
      bold = true,
      nocombine = true,
    },
    Normal = {
      bg = background,
      fg = default.fujiWhite,
    },
    Pmenu = { bg = default.sumiInk3 },
    TelescopePreviewBorder = { bg = theme.ui.bg_dim, fg = theme.ui.bg_dim },
    TelescopePreviewNormal = { bg = theme.ui.bg_dim },
    TelescopePromptBorder = { fg = theme.ui.bg_p1, bg = theme.ui.bg_p1 },
    TelescopePromptNormal = { bg = theme.ui.bg_p1 },
    TelescopeResultsBorder = { fg = theme.ui.bg_m1, bg = theme.ui.bg_m1 },
    TelescopeResultsNormal = { fg = theme.ui.fg_dim, bg = theme.ui.bg_m1 },
    TelescopeTitle = { fg = theme.ui.special, bold = true },
    WinSeparator = { fg = default.sumiInk4 },
    ["@text.title.1"] = {
      fg = default.peachRed,
      bold = true,
    },
    ["@text.title.2"] = {
      fg = default.surimiOrange,
      bold = true,
    },
    ["@text.title.3"] = {
      fg = default.carpYellow,
      bold = true,
    },
    ["@text.title"] = {
      fg = default.crystalBlue,
      bold = true,
    },
    ["@text.reference"] = {
      fg = default.springBlue,
      italic = true,
    },
    ["@text.uri"] = {
      link = "Comment",
    },
  }

  return overrides
end

plug({
  {
    'rebelot/kanagawa.nvim',
    lazy = not vim.startswith(vim.cfg.ui__theme_name, 'kanagawa'),
    cond = vim.cfg.ui__theme_name == "kanagawa",
    opts = {
      undercurl = true, -- enable undercurls
      commentStyle = { italic = true },
      functionStyle = { bold = true },
      keywordStyle = { italic = true },
      statementStyle = { bold = true },
      typeStyle = { bold = true },
      variablebuiltinStyle = { italic = true },
      globalStatus = true,
      colors = {
        theme = {
          all = {
            ui = {
              bg_gutter = "none",
            },
          },
        },
      },
      background = {
        dark = "wave",
        light = "lotus",
      },
    },
    config = function(_, opts)
      opts.overrides = override
      require('kanagawa').setup(opts)
    end
  },

  ----- everforest
  {
    'sainnhe/everforest',
    lazy = vim.cfg.ui__theme_name ~= 'everforest',
    cond = vim.cfg.ui__theme_name == 'everforest',
    priority = 1000,
    init = function()
      vim.g.everforest_background = 'medium'
      vim.g.everforest_ui_contrast = 'low'
      vim.g.everforest_better_performance = 1
      vim.g.everforest_enable_italic = 1
      vim.g.everforest_disable_italic_comment = false
      vim.g.everforest_transparent_background = false
      vim.g.everforest_dim_inactive_windows = false
      vim.g.everforest_sign_column_background = 'none'  -- "none" | "grey"
      vim.g.everforest_diagnostic_virtual_text = 'grey' -- "grey" | "colored"
      vim.g.everforest_diagnostic_text_highlight = 0
      vim.g.everforest_diagnostic_line_highlight = 0
    end
  }
})
