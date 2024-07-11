return {
    {
        'EdenEast/nightfox.nvim',
        priority = 1000,
        event = 'VeryLazy',
        opts = {
            options = {
                transparent = false,
                styles = {
                    keywords = 'italic',
                    types = 'italic,bold',
                },
            },
            groups = {
                all = {
                    WidgetTextHighlight = {
                        fg = 'palette.blue',
                        bg = 'palette.bg0',
                    },
                    FloatBorder = { link = 'NormalFloat' },
                    NormalA = { fg = 'palette.bg0', bg = 'palette.blue' },
                    InsertA = { fg = 'palette.bg0', bg = 'palette.green' },
                    VisualA = { fg = 'palette.bg0', bg = 'palette.magenta' },
                    CommandA = { fg = 'palette.bg0', bg = 'palette.yellow' },
                    TermA = { fg = 'palette.bg0', bg = 'palette.orange' },
                    MotionA = { fg = 'palette.bg0', bg = 'palette.red' },
                    TabLineSel = { fg = 'palette.blue', bg = 'palette.bg3' },
                    TreesitterContext = { bg = 'palette.bg2' },
                    TreesitterContextLineNumber = { link = 'TreesitterContext' },
                    FzfLuaNormal = { link = 'NormalFloat' },
                    FzfLuaBorder = { link = 'FloatBorder' },
                },
                -- https://github.com/EdenEast/nightfox.nvim/blob/main/usage.md#palette
                nordfox = {},
            },
        },
    },

    {
        'rebelot/kanagawa.nvim',
        opts = {
            compile = true,
            undercurl = true, -- enable undercurls
            commentStyle = { italic = true },
            functionStyle = { bold = true },
            keywordStyle = { italic = true },
            statementStyle = { bold = true },
            typeStyle = { bold = true },
            variablebuiltinStyle = { italic = true },
            globalStatus = true,
            overrides = function(colors) -- add/modify highlights
                -- do not foget to run ':KanagawaCompile'
                return {
                    CybuFocus = { link = 'FlashCursor' },
                    MiniIndentscopeSymbol = { link = 'IndentBlanklineChar' },
                    IndentLine = { link = 'IndentBlanklineChar' },
                    IndentLineCurrent = { link = 'IndentBlanklineContextChar' },
                    StatusLine = { bg = colors.theme.syn.fun, fg = colors.theme.ui.bg_m3 },
                    StatusLineNC = { bg = colors.theme.ui.whitespace, fg = colors.theme.ui.fg_dim },
                    TelescopeNormal = { link = 'NormalFloat' },
                    TelescopeBorder = { link = 'FloatBorder' },
                    TelescopeSelection = { link = 'QuickFixLine' },
                    FzfLuaNormal = { link = 'NormalFloat' },
                    FzfLuaBorder = { link = 'FloatBorder' },
                    FzfLuaPreviewNormal = { link = 'NormalFloat' },
                    --- coc
                    CocUnusedHighlight = { link = 'DiagnosticUnderlineHint' },
                    -- flash
                    FlashCursor = { fg = colors.theme.ui.fg, bg = colors.palette.waveBlue1 },
                    WinSeparator = { fg = colors.palette.dragonPink, bg = 'NONE' },
                }
            end,
            colors = {
                palette = {
                    -- + green
                    -- lotusWhite0 = '#B9C8B7',
                    -- lotusWhite1 = '#C2CDBE',
                    -- lotusWhite2 = '#CAD2C5',
                    -- lotusWhite3 = '#E9EDE6',
                    -- lotusWhite4 = '#F3F5F1',
                    -- lotusWhite5 = '#ffffff',

                    --- + solarized
                    lotusWhite0 = '#ECE8D8',
                    lotusWhite1 = '#F5DEAC',
                    lotusWhite2 = '#F3EEDD',
                    --- main bg
                    lotusWhite3 = '#F6EED9',
                    --- tabline etc
                    lotusWhite4 = '#C5C0AF',
                    lotusWhite5 = '#eee8d5',
                },
                theme = {
                    all = {
                        ui = {
                            bg_gutter = 'none',
                        },
                    },
                    lotus = {
                        ui = {
                            bg_p1 = '#DCD7BA',
                            -- bg_m3 = '#586e75',
                        },
                    },
                    dragon = {
                        ui = {},
                    },
                },
            },
            background = {
                -- dark = 'wave',
                dark = 'dragon',
                light = 'lotus',
            },
        },
    },

    {
        'Mofiqul/dracula.nvim',
        name = 'dracula',
        opts = {
            overrides = function(colors)
                return {
                    WidgetTextHighlight = { fg = colors.cyan, bg = colors.black, bold = true },
                    TabLineSel = { fg = colors.purple, bg = colors.bg, bold = true, italic = false },
                    TabLine = { bg = colors.menu, fg = colors.white, italic = true },
                    TabLineFill = { bg = colors.black, fg = colors.purple },
                    StatusLineNC = { fg = colors.comment, bg = colors.menu },
                    NormalA = { fg = colors.black, bg = colors.purple, bold = true },
                    InsertA = { fg = colors.black, bg = colors.green, bold = true },
                    VisualA = { fg = colors.black, bg = colors.blue, bold = true },
                    CommandA = { fg = colors.black, bg = colors.red, bold = true },
                    TermA = { fg = colors.black, bg = colors.yellow, bold = true },
                    MotionA = { fg = colors.black, bg = colors.cyan, bold = true },
                    TreesitterContext = { bg = colors.visual },
                    TreesitterContextLineNumber = { link = 'TreesitterContext' },
                }
            end,
        },
    },
}
