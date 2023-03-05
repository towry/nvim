# Towry's hand crafted NeoVim config

## Folder structure

```txt
lua
└─ ty
   ├─ contrib
   │  ├─ autocmp
   │  │  ├─ autopairs_rc
   │  │  │  ├─ init.lua
   │  │  │  └─ rules.lua
   │  │  ├─ cmp_rc
   │  │  │  └─ init.lua
   │  │  ├─ config.lua
   │  │  ├─ package.lua
   │  │  └─ package_rc.lua
   │  ├─ buffer
   │  │  ├─ func.lua
   │  │  ├─ package.lua
   │  │  ├─ package_rc.lua
   │  │  └─ splits_rc.lua
   │  ├─ common
   │  │  ├─ mini
   │  │  │  └─ init.lua
   │  │  ├─ telescope_rc
   │  │  │  ├─ find-folders-picker.lua
   │  │  │  ├─ init.lua
   │  │  │  ├─ multi-rg-picker.lua
   │  │  │  └─ pickers.lua
   │  │  ├─ legendary_rc.lua
   │  │  ├─ package.lua
   │  │  └─ package_rc.lua
   │  ├─ debugger
   │  │  ├─ dap
   │  │  │  └─ init.lua
   │  │  ├─ neotest
   │  │  │  └─ init.lua
   │  │  ├─ config.lua
   │  │  ├─ package.lua
   │  │  └─ package_rc.lua
   │  ├─ editing
   │  │  ├─ folding
   │  │  │  └─ init.lua
   │  │  ├─ lsp
   │  │  │  ├─ servers
   │  │  │  │  ├─ bashls.lua
   │  │  │  │  ├─ cssls.lua
   │  │  │  │  ├─ eslint.lua
   │  │  │  │  ├─ graphql.lua
   │  │  │  │  ├─ html.lua
   │  │  │  │  ├─ jsonls.lua
   │  │  │  │  ├─ sumneko_lua.lua
   │  │  │  │  ├─ tailwindcss.lua
   │  │  │  │  ├─ tsserver.lua
   │  │  │  │  └─ vuels.lua
   │  │  │  ├─ utils
   │  │  │  │  ├─ defer.lua
   │  │  │  │  └─ documentcolors.lua
   │  │  │  ├─ diagnostics.lua
   │  │  │  ├─ formatting.lua
   │  │  │  ├─ functions.lua
   │  │  │  ├─ init.lua
   │  │  │  ├─ lsp_spinner_notify.lua
   │  │  │  └─ null-ls.lua
   │  │  ├─ config.lua
   │  │  ├─ func.lua
   │  │  ├─ init.lua
   │  │  ├─ package.lua
   │  │  ├─ package_rc.lua
   │  │  ├─ switch_rc.lua
   │  │  └─ yanky_rc.lua
   │  ├─ editor
   │  │  ├─ dashboard
   │  │  │  ├─ alpha.lua
   │  │  │  └─ init.lua
   │  │  ├─ config.lua
   │  │  ├─ func.lua
   │  │  ├─ init.lua
   │  │  ├─ package.lua
   │  │  └─ package_rc.lua
   │  ├─ explorer
   │  ├─ git
   │  ├─ keymaps
   │  ├─ langsupport
   │  ├─ navigate
   │  ├─ statusline
   │  ├─ term
   │  ├─ tools
   │  └─ ui
   ├─ core
   └─ init.lua

```

## Big thanks to

- https://github.com/LazyVim/LazyVim
- https://github.com/ecosse3/nvim
- https://github.com/glepnir/dope
- others mentioned in the code.
