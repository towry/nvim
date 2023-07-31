local plug = require('userlib.runtime.pack').plug

plug({
  'rebelot/kanagawa.nvim',
  event = 'User LazyTheme',
  enabled = string.match(vim.cfg.ui__theme_name, 'kanagawa') ~= nil,
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
      palette = {
        dragonBlack0 = "#191f24",
        dragonBlack1 = "#1c2228",
        dragonBlack2 = "#192024",
        dragonBlack3 = "#1c2428",
        dragonBlack4 = "#232c30",
        dragonBlack5 = "#2b353b",
        dragonBlack6 = "#3b464f",
        dragonBlue2 = "#7b96a3",
        winterBlue = "#223140",

        --- https://coolors.co/f5f4f2-f8f7f6-f9f9f8-fafafa-f1f5f1-dee2de-d4d8d4-caceca-a2a6a3-212121
        lotusWhite0 = "#ebedf2",
        lotusWhite1 = "#f8f7f6",
        lotusWhite2 = "#f9f9f8",
        lotusWhite3 = "#f5f4f2",
        lotusWhite4 = "#edebe3",
        lotusWhite5 = "#e9e6db",
      },
      theme = {
        all = {
          ui = {
            bg_gutter = "none",
          },
        },
      },
    },
    background = {
      -- dark = "wave",
      dark = 'dragon',
      light = "lotus",
    },
  },
})
