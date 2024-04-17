" Name:         desert
" Description:  Light background colorscheme.
" Author:       Original author Hans Fugal <hans@fugal.net>
" Maintainer:   Original maintainer Hans Fugal <hans@fugal.net>
" Website:      https://github.com/vim/colorschemes
" License:      Same as Vim
" Last Updated: Fri 15 Dec 2023 20:05:34

" Generated by Colortemplate v2.2.3

set background=dark

" Remove all existing highlighting and set the defaults.
hi clear

" Load the syntax highlighting defaults, if it's enabled.
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = 'term'

let s:t_Co = &t_Co

hi! link Terminal Normal
hi! link LineNrAbove LineNr
hi! link LineNrBelow LineNr
hi! link CurSearch Search
hi! link CursorLineFold CursorLine
hi! link CursorLineSign CursorLine
hi! link EndOfBuffer Normal
hi! link MessageWindow Pmenu
hi! link PopupNotification Todo

hi Normal guibg=NONE
hi NormalFloat guibg=black
hi TabLine guifg=grey guibg=black gui=NONE
hi TabLineFill guifg=grey guibg=dark gui=NONE
hi TabLineSel guifg=black guibg=white gui=NONE

" -+++
" +--- Treesitter
hi! link @string ui_txt_br
" -+++

" +--- Plugins
" --- coc
hi! link CocErrorSign DiagnosticError
hi! link CocWarningSign DiagnosticWarn
hi! link CocInfoSign DiagnosticInfo
hi! link CocHintSign DiagnosticHint
hi! link CocErrorFloat DiagnosticError
hi! link CocWarningFloat DiagnosticWarn
hi! link CocInfoFloat DiagnosticInfo
hi! link CocHintFloat DiagnosticHint
hi! link CocDiagnosticsError DiagnosticError
hi! link CocDiagnosticsWarning DiagnosticWarn
hi! link CocDiagnosticsInfo DiagnosticInfo
hi! link CocDiagnosticsHint DiagnosticHint
hi! link CocSelectedText Search
hi! link CocCodeLens Comment
hi! link CocMenuSel PmenuSel
" --- mini
" --- Telescope
hi! link TelescopeSelection CursorLine
hi! link TelescopeSelectionCaret CursorLineNr
" --- fzf-lua
" -+++


if s:t_Co >= 16
  hi Normal ctermfg=white ctermbg=black cterm=NONE
  hi StatusLine ctermfg=black ctermbg=grey cterm=NONE
  hi StatusLineNC ctermfg=darkgrey ctermbg=grey cterm=NONE
  hi StatusLineTerm ctermfg=black ctermbg=grey cterm=NONE
  hi StatusLineTermNC ctermfg=darkgrey ctermbg=grey cterm=NONE
  hi VertSplit ctermfg=darkgrey ctermbg=grey cterm=NONE
  hi Pmenu ctermfg=NONE ctermbg=darkgrey cterm=NONE
  hi PmenuSel ctermfg=black ctermbg=yellow cterm=NONE
  hi PmenuSbar ctermfg=NONE ctermbg=black cterm=NONE
  hi PmenuThumb ctermfg=NONE ctermbg=white cterm=NONE
  hi TabLine ctermfg=black ctermbg=grey cterm=NONE
  hi TabLineFill ctermfg=NONE ctermbg=white cterm=NONE
  hi TabLineSel ctermfg=white ctermbg=black cterm=NONE
  hi ToolbarLine ctermfg=NONE ctermbg=NONE cterm=NONE
  hi ToolbarButton ctermfg=black ctermbg=darkyellow cterm=NONE
  hi NonText ctermfg=blue ctermbg=NONE cterm=NONE
  hi SpecialKey ctermfg=darkgreen ctermbg=NONE cterm=NONE
  hi Folded ctermfg=darkblue ctermbg=NONE cterm=NONE
  hi Visual ctermfg=white ctermbg=darkgreen cterm=NONE
  hi VisualNOS ctermfg=NONE ctermbg=NONE cterm=underline
  hi LineNr ctermfg=darkyellow ctermbg=NONE cterm=NONE
  hi FoldColumn ctermfg=darkyellow ctermbg=darkgrey cterm=NONE
  hi CursorLine ctermfg=NONE ctermbg=NONE cterm=underline
  hi CursorColumn ctermfg=NONE ctermbg=NONE cterm=NONE
  hi CursorLineNr ctermfg=darkyellow ctermbg=NONE cterm=bold
  hi QuickFixLine ctermfg=black ctermbg=yellow cterm=NONE
  hi SignColumn ctermfg=NONE ctermbg=NONE cterm=NONE
  hi Underlined ctermfg=darkblue ctermbg=NONE cterm=underline
  hi Error ctermfg=red ctermbg=white cterm=reverse
  hi ErrorMsg ctermfg=red ctermbg=white cterm=reverse
  hi ModeMsg ctermfg=magenta ctermbg=NONE cterm=bold
  hi WarningMsg ctermfg=darkred ctermbg=NONE cterm=bold
  hi MoreMsg ctermfg=darkgreen ctermbg=NONE cterm=bold
  hi Question ctermfg=green ctermbg=NONE cterm=bold
  hi Todo ctermfg=red ctermbg=darkmagenta cterm=NONE
  hi MatchParen ctermfg=black ctermbg=darkyellow cterm=NONE
  hi Search ctermfg=black ctermbg=darkgreen cterm=NONE
  hi IncSearch ctermfg=black ctermbg=yellow cterm=NONE
  hi WildMenu ctermfg=black ctermbg=darkmagenta cterm=NONE
  hi ColorColumn ctermfg=white ctermbg=darkred cterm=NONE
  hi debugPC ctermfg=grey ctermbg=NONE cterm=reverse
  hi debugBreakpoint ctermfg=cyan ctermbg=NONE cterm=reverse
  hi SpellBad ctermfg=darkred ctermbg=darkyellow cterm=reverse
  hi SpellCap ctermfg=darkblue ctermbg=grey cterm=reverse
  hi SpellLocal ctermfg=darkyellow ctermbg=NONE cterm=reverse
  hi SpellRare ctermfg=darkgreen ctermbg=NONE cterm=reverse
  hi Comment ctermfg=cyan ctermbg=NONE cterm=NONE
  hi Identifier ctermfg=green ctermbg=NONE cterm=NONE
  hi Statement ctermfg=yellow ctermbg=NONE cterm=bold
  hi Constant ctermfg=darkmagenta ctermbg=NONE cterm=NONE
  hi PreProc ctermfg=darkred ctermbg=NONE cterm=NONE
  hi Type ctermfg=darkyellow ctermbg=NONE cterm=bold
  hi Special ctermfg=magenta ctermbg=NONE cterm=NONE
  hi Directory ctermfg=blue ctermbg=NONE cterm=NONE
  hi Conceal ctermfg=grey ctermbg=NONE cterm=NONE
  hi Ignore ctermfg=NONE ctermbg=NONE cterm=NONE
  hi Title ctermfg=darkred ctermbg=NONE cterm=bold
  hi DiffAdd ctermfg=white ctermbg=darkgreen cterm=NONE
  hi DiffChange ctermfg=white ctermbg=blue cterm=NONE
  hi DiffText ctermfg=black ctermbg=grey cterm=NONE
  hi DiffDelete ctermfg=white ctermbg=magenta cterm=NONE
  unlet s:t_Co
  finish
endif

if s:t_Co >= 8
  hi Normal ctermfg=grey ctermbg=black cterm=NONE
  hi StatusLine ctermfg=grey ctermbg=black cterm=bold,reverse
  hi StatusLineNC ctermfg=grey ctermbg=black cterm=reverse
  hi StatusLineTerm ctermfg=grey ctermbg=black cterm=bold,reverse
  hi StatusLineTermNC ctermfg=grey ctermbg=black cterm=reverse
  hi VertSplit ctermfg=grey ctermbg=black cterm=reverse
  hi Pmenu ctermfg=black ctermbg=darkcyan cterm=NONE
  hi PmenuSel ctermfg=black ctermbg=darkyellow cterm=NONE
  hi PmenuSbar ctermfg=NONE ctermbg=black cterm=NONE
  hi PmenuThumb ctermfg=NONE ctermbg=grey cterm=NONE
  hi TabLine ctermfg=black ctermbg=grey cterm=NONE
  hi TabLineFill ctermfg=NONE ctermbg=grey cterm=NONE
  hi TabLineSel ctermfg=grey ctermbg=black cterm=NONE
  hi ToolbarLine ctermfg=NONE ctermbg=NONE cterm=NONE
  hi ToolbarButton ctermfg=grey ctermbg=black cterm=bold,reverse
  hi NonText ctermfg=darkblue ctermbg=NONE cterm=bold
  hi SpecialKey ctermfg=darkgreen ctermbg=NONE cterm=NONE
  hi Folded ctermfg=darkblue ctermbg=NONE cterm=NONE
  hi Visual ctermfg=NONE ctermbg=NONE cterm=reverse
  hi VisualNOS ctermfg=NONE ctermbg=NONE cterm=underline
  hi LineNr ctermfg=darkyellow ctermbg=NONE cterm=NONE
  hi FoldColumn ctermfg=darkyellow ctermbg=NONE cterm=NONE
  hi CursorLine ctermfg=NONE ctermbg=NONE cterm=underline
  hi CursorColumn ctermfg=NONE ctermbg=NONE cterm=NONE
  hi CursorLineNr ctermfg=darkyellow ctermbg=NONE cterm=bold
  hi QuickFixLine ctermfg=black ctermbg=darkyellow cterm=NONE
  hi SignColumn ctermfg=NONE ctermbg=NONE cterm=NONE
  hi Underlined ctermfg=NONE ctermbg=NONE cterm=underline
  hi Error ctermfg=darkred ctermbg=grey cterm=reverse
  hi ErrorMsg ctermfg=darkred ctermbg=grey cterm=reverse
  hi ModeMsg ctermfg=darkmagenta ctermbg=NONE cterm=bold
  hi WarningMsg ctermfg=darkred ctermbg=NONE cterm=bold
  hi MoreMsg ctermfg=darkgreen ctermbg=NONE cterm=bold
  hi Question ctermfg=darkgreen ctermbg=NONE cterm=bold
  hi Todo ctermfg=darkred ctermbg=darkmagenta cterm=NONE
  hi MatchParen ctermfg=black ctermbg=darkyellow cterm=NONE
  hi Search ctermfg=black ctermbg=darkgreen cterm=NONE
  hi IncSearch ctermfg=black ctermbg=darkyellow cterm=NONE
  hi WildMenu ctermfg=black ctermbg=darkmagenta cterm=NONE
  hi ColorColumn ctermfg=grey ctermbg=darkred cterm=NONE
  hi debugPC ctermfg=grey ctermbg=NONE cterm=reverse
  hi debugBreakpoint ctermfg=darkcyan ctermbg=NONE cterm=reverse
  hi SpellBad ctermfg=darkred ctermbg=darkyellow cterm=reverse
  hi SpellCap ctermfg=darkblue ctermbg=grey cterm=reverse
  hi SpellLocal ctermfg=darkyellow ctermbg=NONE cterm=reverse
  hi SpellRare ctermfg=darkgreen ctermbg=NONE cterm=reverse
  hi Comment ctermfg=darkcyan ctermbg=NONE cterm=bold
  hi Identifier ctermfg=darkgreen ctermbg=NONE cterm=NONE
  hi Statement ctermfg=darkyellow ctermbg=NONE cterm=bold
  hi Constant ctermfg=darkmagenta ctermbg=NONE cterm=NONE
  hi PreProc ctermfg=darkred ctermbg=NONE cterm=NONE
  hi Type ctermfg=darkyellow ctermbg=NONE cterm=bold
  hi Special ctermfg=darkmagenta ctermbg=NONE cterm=bold
  hi Directory ctermfg=darkblue ctermbg=NONE cterm=bold
  hi Conceal ctermfg=grey ctermbg=NONE cterm=NONE
  hi Ignore ctermfg=NONE ctermbg=NONE cterm=NONE
  hi Title ctermfg=darkred ctermbg=NONE cterm=bold
  hi DiffAdd ctermfg=white ctermbg=darkgreen cterm=NONE
  hi DiffChange ctermfg=white ctermbg=darkblue cterm=NONE
  hi DiffText ctermfg=black ctermbg=grey cterm=NONE
  hi DiffDelete ctermfg=white ctermbg=darkmagenta cterm=NONE
  unlet s:t_Co
  finish
endif

if s:t_Co >= 0
  hi Normal term=NONE
  hi ColorColumn term=reverse
  hi Conceal term=NONE
  hi Cursor term=reverse
  hi CursorColumn term=NONE
  hi CursorLine term=underline
  hi CursorLineNr term=bold
  hi DiffAdd term=reverse
  hi DiffChange term=NONE
  hi DiffDelete term=reverse
  hi DiffText term=reverse
  hi Directory term=NONE
  hi EndOfBuffer term=NONE
  hi ErrorMsg term=bold,reverse
  hi FoldColumn term=NONE
  hi Folded term=NONE
  hi IncSearch term=bold,reverse,underline
  hi LineNr term=NONE
  hi MatchParen term=bold,underline
  hi ModeMsg term=bold
  hi MoreMsg term=NONE
  hi NonText term=NONE
  hi Pmenu term=reverse
  hi PmenuSbar term=reverse
  hi PmenuSel term=bold
  hi PmenuThumb term=NONE
  hi Question term=standout
  hi Search term=reverse
  hi SignColumn term=reverse
  hi SpecialKey term=bold
  hi SpellBad term=underline
  hi SpellCap term=underline
  hi SpellLocal term=underline
  hi SpellRare term=underline
  hi StatusLine term=bold,reverse
  hi StatusLineNC term=bold,underline
  hi TabLine term=bold,underline
  hi TabLineFill term=NONE
  hi Terminal term=NONE
  hi TabLineSel term=bold,reverse
  hi Title term=NONE
  hi VertSplit term=NONE
  hi Visual term=reverse
  hi VisualNOS term=NONE
  hi WarningMsg term=standout
  hi WildMenu term=bold
  hi CursorIM term=NONE
  hi ToolbarLine term=reverse
  hi ToolbarButton term=bold,reverse
  hi CurSearch term=reverse
  hi CursorLineFold term=underline
  hi CursorLineSign term=underline
  hi Comment term=bold
  hi Constant term=NONE
  hi Error term=bold,reverse
  hi Identifier term=NONE
  hi Ignore term=NONE
  hi PreProc term=NONE
  hi Special term=NONE
  hi Statement term=NONE
  hi Todo term=bold,reverse
  hi Type term=NONE
  hi Underlined term=underline
  unlet s:t_Co
  finish
endif

" vim: et ts=8 sw=2 sts=2
