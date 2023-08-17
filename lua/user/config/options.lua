local M = {}
local o = vim.opt
local g = vim.g

function M.init_edit()
  o.cpoptions:append(">")                    -- append to register with line break
  o.inccommand = 'nosplit'                   -- preview incremental substitute
  o.clipboard = { 'unnamed', 'unnamedplus' } --- Copy-paste between vim and everything else
  o.expandtab = true                         --- Use spaces instead of tabs
  o.ignorecase = true                        --- Needed for smartcase
  o.textwidth = 80
  o.shiftwidth = 2                           --- Change a number of space characeters inseted for indentation
  o.shiftround = true                        -- round indent.
  o.smartcase = true                         --- Uses case in search
  o.smartindent = true                       --- Makes indenting smart
  o.smarttab = true                          --- Makes tabbing smarter will realize you have 2 vs 4
  o.softtabstop = 2                          --- Insert 2 spaces for a tab
  o.splitright = true                        --- Vertical splits will automatically be to the right
  o.swapfile = false                         --- Swap not needed
  o.tabstop = 2                              --- Insert 2 spaces for a tab
  o.timeoutlen = 400                         --- Key sequence wait time | Faster completion (cannot be lower than 200 because then commenting doesn't work)
  o.showcmd = true
  o.showcmdloc = 'last'
  o.winminwidth = 10
  o.winwidth = 10
  o.equalalways = false
  o.showmatch = false                              -- show {} match and jump
  o.undofile = true                                --- Sets undo to file
  o.updatetime = 250                               --- Faster completion
  -- o.viminfo        = "'1000" --- Increase the size of file history
  o.wildignore = { '*node_modules/**', '.git/**' } --- Don't search inside Node.js modules (works for gutentag)
  o.wrap = false                                   --- Display long lines as just one line
  o.writebackup = false                            --- Not needed
  o.autoindent = true                              --- Good auto indent
  o.backspace = { 'indent', 'eol', 'start' }       --- Making sure backspace works
  o.backup = false                                 --- Recommended by coc
  o.conceallevel = 0                               --- Show `` in markdown files
  o.encoding = 'utf-8'                             --- The encoding displayed
  o.errorbells = false                             --- Disables sound effect for errors
  o.fileencoding = 'utf-8'                         --- The encoding written to file
  o.incsearch = true                               --- Start searching before pressing enter
  o.switchbuf = 'usetab'                           -- Use already opened buffers when switching
  o.diffopt:append { "algorithm:histogram", "foldcolumn:0", "vertical", "linematch:50" }
  -- o.shellcmdflag = '-ic' --- Make shell alias works, has bugs.
end

function M.init_interface()
  o.colorcolumn =
  '+1'                                               -- Draw colored column one step to the right of desired maximum width
  o.showmode = false                                 --- Don't show things like -- INSERT -- anymore
  o.modeline = true                                  -- Allow modeline
  o.ruler = false                                    -- Always show cursor position
  o.termguicolors = true                             --- Correct terminal colors
  o.confirm = true
  o.showtabline = 0                                  --- Always show tabs
  o.signcolumn = 'yes:1'                             --- Add extra sign column next to line number
  o.relativenumber = vim.cfg.editor__relative_number --- Enables relative number
  o.numberwidth = 1
  o.number = true                                    --- Shows current line number
  o.pumheight = 10                                   --- Max num of items in completion menu
  o.pumblend = 17                                    -- popup blend
  o.scrolloff = 10                                   --- Always keep space when scrolling to bottom/top edge
  -- o.smoothscroll = true
  o.sidescroll = 2                                   --- Used only when 'wrap' option is off and the cursor is moved off the screen.
  o.mouse = 'a'                                      --- Enable mouse
  o.sidescrolloff = 8                                -- Columns of context
  o.lazyredraw = false                               --- Makes macros faster & prevent errors in complicated mappings
  o.wildmode = { 'longest:full', 'full' }            -- Command-line completion mode
  o.cmdheight = 1                                    --- Give more space for displaying messages
  o.completeopt = { 'menu', 'menuone', 'noselect' }  --- Better autocompletion
  o.cursorline = true                                --- Highlight of current line
  o.emoji = true                                     --- Fix emoji display
  o.cursorlineopt = 'both'
  o.foldcolumn = '1'                                 -- Folding
  o.list = true
  o.listchars:append('tab:⇢ ')
  o.listchars:append('eol:↲')
  o.listchars:append('extends:»')
  o.listchars:append('nbsp:␣')
  o.listchars:append('precedes:«')
  o.fillchars        = {
    stl = ' ',
    stlnc = ' ',
    eob = ' ',
    fold = ' ',
    foldsep = ' ',
    foldopen = '',
    foldclose = '',
  }
  vim.o.statuscolumn =
  '%s%=%{v:relnum?v:relnum:v:lnum} %{foldlevel(v:lnum) > 0 ? (foldlevel(v:lnum) > foldlevel(v:lnum - 1) ? (foldclosed(v:lnum) == -1 ? "" : "") : "│") : "│" } '
  o.laststatus       = 3 --- Have a global statusline at the bottom instead of one for each window
  o.shortmess:append({ W = true, I = true, c = true, F = true })
  if vim.fn.has('nvim-0.9.0') == 1 then
    o.splitkeep = 'screen'
    o.shortmess:append({ C = true })
  end
  -- o.formatoptions:append {
  --   r = true, -- Automatically insert comment leader after <Enter> in Insert mode.
  --   o = true, -- Automatically insert comment leader after 'o' or 'O' in Normal mode.
  --   l = true, -- Long lines are not broken in insert mode.
  --   t = true, -- Do not auto wrap text
  --   n = true, -- Recognise lists
  -- }
  o.formatoptions:remove('c')
  o.formatoptions:remove('r')
  o.formatoptions:remove('o')
  if vim.fn.executable('rg') then
    -- credit: https://github.com/nicknisi/dotfiles/blob/1360edda1bbb39168637d0dff13dd12c2a23d095/config/nvim/init.lua#L73
    -- if ripgrep installed, use that as a grepper
    o.grepprg = "rg --vimgrep --color=never --with-filename --line-number --no-heading --smart-case --"
    o.grepformat = "%f:%l:%c:%m,%f:%l:%m"
  end
end

function M.init_folds()
  local function enable_foldexpr()
    if vim.api.nvim_buf_line_count(0) > 40000 then
      return
    end
    vim.opt_local.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.opt_local.foldmethod = 'expr'
    -- below will move cursor move
    -- vim.cmd.normal 'zx'
  end

  vim.api.nvim_create_autocmd('FileType', {
    -- schedule_wrap is used to stop dlopen from crashing on MacOS
    callback = vim.schedule_wrap(function()
      if not pcall(vim.treesitter.start) or vim.wo.diff then
        return
      end

      enable_foldexpr()
    end)
  })
  o.foldnestmax = 10    -- deepest fold is 10 levels
  o.foldlevel = 99      --- Using ufo provider need a large value
  o.foldlevelstart = 99 --- Expand all folds by default
end

function M.init_other()
  g.python3_host_prog = vim.cfg.runtime__python3_host_prog
  -- Fix markdown indentation settings
  g.markdown_recommended_style = 0

  -- built-in plugins disable.
  for _, plugin in ipairs(vim.cfg.runtime__disable_builtin_plugins) do
    local var = "loaded_" .. plugin
    vim.g[var] = 1
  end
  -- built-in neovim RPC provider disable
  for _, provider in ipairs(vim.cfg.runtime__disable_builtin_provider) do
    local var = "loaded_" .. provider .. "_provider"
    vim.g[var] = 0
  end
end

--- called by statusline component on load.
function M.setup_statusline()
  vim.opt.showtabline = 0 --- Always show tabs
  vim.opt.laststatus = 3  --- Have a global statusline at the bottom instead of one for each window
  -- in nvim-tree or windows picker, the laststatus will be modified
end

--- need to lazy setup, otherwise bunch mods needed to be load.
function M.setup_lsp()
  if vim.cfg.lsp__log_level then
    vim.lsp.set_log_level(vim.cfg.lsp__log_level)
  end
end

function M.setup()
  vim.g.mapleader = ' '
  vim.g.maplocalleader = ','

  M.init_edit()
  M.init_interface()
  M.init_folds()
  M.init_other()
end

return M
