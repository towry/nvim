-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

do --- LazyVim Options
    vim.g.lazyvim_picker = 'fzf'
    vim.g.lazygit_config = false
end

do --- User Custom Options
    vim.g.cfg_root_cwd = vim.uv.cwd()
    ---@type 'coq' | 'coc' | 'native' | 'cmp'
    vim.g.cfg_cmp_provider = 'coq'
    ---@type "clue" | "whichkey"
    vim.g.cfg_keymap_hint_helper = 'clue'
    ---@type "single" | "rounded" | "double" | "shadow"
    vim.g.cfg_border_style = 'single'
    ---@type {git: boolean}
    vim.g.cfg_inside = setmetatable({}, {
        __index = function(_, key)
            local v = require('v')
            if key == 'git' then
                v.git_is_using_nvim_as_tool()
            end
        end,
    })
    ---  Vim not opening a file.
    vim.g.cfg_empty_argc = vim.fn.argc(-1) == 0
    vim.g.cfg_resize_steps = 10
    vim.g.cfg_bigfile_size = 1024 * 1024 * 1.5 -- 1.5MB
    vim.g.cfg_disabled_plugins = {
        'gzip',
        'zip',
        'zipPlugin',
        'tar',
        'tarPlugin',
        'getscript',
        'getscriptPlugin',
        'vimball',
        'vimballPlugin',
        '2html_plugin',
        'matchit',
        'matchparen',
        'logiPat',
        'rust_vim',
        'rust_vim_plugin_cargo',
        'rrhelper',
        'netrw',
        'netrwPlugin',
        'netrwSettings',
        'netrwFileHandlers',
    }
    vim.g.cfg_disabled_providers = {
        'perl',
        'ruby',
    }
end

--- ======================================
local o = vim.opt
local g = vim.g

g.mapleader = ' '
g.maplocalleader = ','
o.autowrite = true
--- Make sure path working correctly in nix env
if vim.o.shell and vim.o.shell:find('fish') then
    o.shellcmdflag = ('--init-command="set PATH %s" -Pc'):format(vim.env.PATH)
end
o.clipboard = { 'unnamed', 'unnamedplus' } --- Copy-paste between vim and everything else
--- blink cursor see https://github.com/neovim/neovim/pull/26075
o.guicursor = {
    -- 'n:blinkon1',
    'n-v-c-sm:block-Cursor/lCursor',
    'i-ci-ve:ver25-Cursor/lCursor',
    'r-cr-o:hor20-Cursor/lCursor',
}
o.report = 9001         -- Threshold for reporting number of lines channged.
o.colorcolumn = ''      -- Draw colored column one step to the right of desired maximum width
o.showmode = false      --- Don't show things like -- INSERT -- anymore
o.modeline = true       -- Allow modeline
o.ruler = false         -- Always show cursor position
o.termguicolors = true  --- Correct terminal colors
o.confirm = true
o.showtabline = 2       --- Always show tabs
o.signcolumn = 'yes:1'  --- Add extra sign column next to line number
o.relativenumber = true --- Enables relative number
o.numberwidth = 1
o.number = true         --- Shows current line number
o.pumheight = 8         --- Max num of items in completion menu
o.pumblend = 0          -- popup blend
o.startofline = false   -- cursor start of line when scroll
o.showbreak = '↳ '
-- o.jumpoptions = 'stack,view'
pcall(function()
    -- NOTE: unload is experimental
    o.jumpoptions = 'stack,view,unload'
end)
o.cursorlineopt = 'line,number'
o.foldcolumn = '1' -- Folding
o.wildmenu = true
-- longest: CmdA, CmdB, 'Cmd' is longest match
o.wildmode = { 'longest:full', 'list:longest', 'list:full' } -- Command-line completion mode
o.wildignorecase = true
o.wildoptions = { 'fuzzy', 'tagfile' }
o.wildignore = { '*.pyc', '*node_modules/**', '.git/**', '*.DS_Store', '*.min.js', '*.obj' } --- Don't search inside Node.js modules (works for gutentag)
o.cmdheight = 1                                                                              --- Give more space for displaying messages
o.cmdwinheight = 10                                                                          -- the cmd window height
o.completeopt = 'menu,noinsert,noselect,popup,fuzzy'                                         --- Better autocompletion
o.complete:append('kspell')                                                                  -- Add spellcheck options for autocomplete
-- scan current and included files.
-- o.complete:append('i')
-- scan current and included files for defined name or macro
-- o.complete:append('d')
-- scan buffer name
o.complete:append('f')
o.shada:append('r/tmp/')
o.shada:append('r*://')
o.shada:append('r*://')
o.shada:append('r.git/*')
o.list = true
o.listchars:append('tab:· ')
-- o.listchars:append('eol:↩')
o.listchars:append('extends:»')
o.listchars:append('nbsp:␣')
o.listchars:append('precedes:«')
o.statuscolumn = '%#SignColumn#%s%l%C'
o.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' }
o.splitkeep = 'screen'
o.foldnestmax = 10 -- deepest fold is 10 levels
o.foldlevel = 99   --- Using ufo provider need a large value
o.foldlevelstart = 99
for _, provider in ipairs(vim.g.cfg_disabled_providers) do
    local var = 'loaded_' .. provider .. '_provider'
    vim.g[var] = 0
end
vim.opt.laststatus = 2
if vim.g.cfg_inside.git then
    vim.opt.laststatus = 2
    pcall(function()
        _G.V_stl_git_three_way_name = function()
            local bufname = vim.api.nvim_buf_get_name(0)
            local basename = vim.fn.fnamemodify(bufname, ':t')
            if vim.bo.filetype == 'gitcommit' then
                return ''
            end
            if basename == 'RCONFL' then
                return 'REMOTE'
            end
            -- if basename contains REMOTE
            if vim.fn.match(basename, '_REMOTE_') ~= -1 then
                return 'REMOTE'
            elseif vim.fn.match(basename, '_LOCAL_') ~= -1 then
                return 'LOCAL'
            elseif vim.fn.match(basename, '_BASE_') ~= -1 then
                return 'BASE'
            else
                return 'MERGED'
            end
        end
    end)
    vim.opt.statusline = [[%<%n#%f %q%h%m%r[%{v:lua.V_stl_git_three_way_name()}]%=%-14.(%l,%c%V%)%p%% %y %w]]
end
-- ===
---------------------------------------------
vim.filetype.add({
    pattern = {
        ['.*'] = {
            function(path, buf)
                return vim.bo[buf]
                    and vim.bo[buf].filetype ~= 'bigfile'
                    and path
                    and vim.fn.getfsize(path) > vim.g.cfg_bigfile_size
                    and 'bigfile'
                    or nil
            end,
        },
    },
})
