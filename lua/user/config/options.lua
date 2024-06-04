local M = {}
local o = vim.opt
local g = vim.g

function M.startup()
  o.shell = ('%s/.nix-profile/bin/fish'):format(vim.env.HOME)
  o.winbar = ''
  o.autowrite = true
  o.startofline = false -- cursor start of line when scroll
  o.exrc = true
  o.jumpoptions = 'stack,view'
  o.path = '**' -- use a recursive path for :find
  o.breakindent = true
  o.cpoptions:append('>') -- append to register with line break
  o.inccommand = 'nosplit' -- preview incremental substitute
  o.expandtab = true --- Use spaces instead of tabs
  o.ignorecase = true --- Needed for smartcase
  o.textwidth = 80
  o.shiftwidth = 2 --- Change a number of space characeters inseted for indentation
  o.shiftround = true -- round indent.
  o.smartcase = true --- Uses case in search
  o.smartindent = true --- Makes indenting smart
  o.smarttab = true --- Makes tabbing smarter will realize you have 2 vs 4
  o.softtabstop = 2 --- Insert 2 spaces for a tab
  o.splitright = true --- Vertical splits will automatically be to the right
  o.splitbelow = true
  o.swapfile = false --- Swap not needed
  o.tabstop = 2 --- Insert 2 spaces for a tab
  o.timeoutlen = 450 --- Key sequence wait time | Faster completion (cannot be lower than 200 because then commenting doesn't work)
  o.showcmd = true
  o.showcmdloc = 'statusline'
  o.winminwidth = 10
  o.winwidth = 10
  o.equalalways = vim.cfg.ui__window_equalalways
  o.winfixwidth = false
  o.winfixheight = false
  o.showmatch = false -- show {} match and jump
  o.undofile = true --- Sets undo to file
  o.undolevels = 10000
  o.updatetime = 250 --- Faster completion
  -- o.viminfo        = "'1000" --- Increase the size of file history
  o.wrap = true --- Display long lines as just one line
  o.linebreak = true
  o.showbreak = '↳ '
  -- enable line-wrapping with left and right cursor movement
  vim.opt.whichwrap:append({ ['<'] = true, ['>'] = true, ['h'] = true, ['l'] = true, ['['] = true, [']'] = true })
  -- add @, -, and $ as keywords for full SCSS support
  vim.opt.iskeyword:append({ '@-@', '-', '$' })
  o.writebackup = false --- Not needed
  o.autoindent = true --- Good auto indent
  o.backspace = { 'indent', 'eol', 'start' } --- Making sure backspace works
  o.backup = false --- Recommended by coc
  o.conceallevel = 0 --- Show `` in markdown files
  -- o.concealcursor = 'i'
  o.encoding = 'utf-8' --- The encoding displayed
  o.errorbells = false --- Disables sound effect for errors
  o.fileencoding = 'utf-8' --- The encoding written to file
  o.incsearch = true --- Start searching before pressing enter
  o.gdefault = true
  o.switchbuf = 'useopen,uselast' -- Use already opened buffers when switching
  o.synmaxcol = 300
  o.diffopt:append({ 'algorithm:histogram', 'foldcolumn:0', 'vertical', 'linematch:50' })
  -- o.shellcmdflag = '-ic' --- Make shell alias works, has bugs.
  o.virtualedit = 'onemore'
  -- load this early to avoid :intro screen.
  o.shortmess:append({
    a = true,
    -- don't give ins-completion-menu messages.
    c = true,
    -- don't give messages while scanning for ins-completion-menu
    C = true,
    F = true,
    I = true,
    T = true,
    W = true,
    q = false,
    t = true,
  })
  vim.opt.laststatus = 0 --- never on startup, setup later by plugin
  o.fillchars = {
    stl = ' ',
    stlnc = ' ',
    eob = ' ',
    fold = ' ',
    foldsep = ' ',
    foldopen = '',
    foldclose = '',
    diff = ' ',
  }
end

function M.init_interface()
  o.clipboard = { 'unnamed', 'unnamedplus' } --- Copy-paste between vim and everything else
  --- blink cursor see https://github.com/neovim/neovim/pull/26075
  --- set guicursor+=n:blinkon1
  -- o.guicursor:append('n-v-c:blinkon500-blinkoff500')
  o.report = 9001 -- Threshold for reporting number of lines channged.
  o.colorcolumn = '' -- Draw colored column one step to the right of desired maximum width
  o.showmode = false --- Don't show things like -- INSERT -- anymore
  o.modeline = true -- Allow modeline
  o.ruler = false -- Always show cursor position
  o.termguicolors = true --- Correct terminal colors
  o.confirm = true
  o.showtabline = vim.cfg.runtime__starts_as_gittool and 2 or 2 --- Always show tabs
  o.signcolumn = 'yes:1' --- Add extra sign column next to line number
  o.relativenumber = vim.cfg.editor__relative_number and not vim.cfg.runtime__starts_as_gittool --- Enables relative number
  o.numberwidth = 1
  o.number = true --- Shows current line number
  o.pumheight = 8 --- Max num of items in completion menu
  o.pumblend = 0 -- popup blend
  o.infercase = true -- Infer letter cases for a richer built-in keyword completion
  o.scrolloff = 2 --- Always keep space when scrolling to bottom/top edge
  -- o.smoothscroll = true
  if vim.fn.has('nvim-0.10') == 1 then
    o.smoothscroll = true
  end
  o.sidescroll = 0 --- Used only when 'wrap' option is off and the cursor is moved off the screen.
  o.mouse = 'a' --- Enable mouse
  o.sidescrolloff = 0 -- Columns of context, should be disabled inside term(cause term scroll left a bit)
  o.lazyredraw = true --- lazyredraw on startup
  o.wildmenu = true
  -- longest: CmdA, CmdB, 'Cmd' is longest match
  o.wildmode = { 'full', 'full:longest', 'list:full', 'lastused' } -- Command-line completion mode
  o.wildignorecase = true
  o.wildoptions = { 'fuzzy', 'pum', 'tagfile' }
  o.wildignore = { '*.pyc', '*node_modules/**', '.git/**', '*.DS_Store', '*.min.js', '*.obj' } --- Don't search inside Node.js modules (works for gutentag)
  o.cmdheight = 1 --- Give more space for displaying messages
  o.cmdwinheight = 10 -- the cmd window height
  o.completeopt = 'menu,noinsert,noselect,preview,popup' --- Better autocompletion
  o.complete:append('kspell') -- Add spellcheck options for autocomplete
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
  -- o.complete:remove('t')
  o.cursorline = true --- Highlight of current line
  o.emoji = true --- Fix emoji display
  o.cursorlineopt = 'line,number'
  o.foldcolumn = '1' -- Folding
  o.foldopen:remove('hor')
  if vim.fn.has('nvim-0.10') == 1 then
    vim.opt.foldmethod = 'expr'
    vim.opt.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
    vim.opt.foldtext = ''
    vim.opt.fillchars = 'fold: '
  else
    vim.opt.foldmethod = 'indent'
  end
  o.list = true
  o.listchars:append('tab:· ')
  -- o.listchars:append('eol:↩')
  o.listchars:append('extends:»')
  o.listchars:append('nbsp:␣')
  o.listchars:append('precedes:«')
  -- o.listchars:append('trail:-')
  vim.o.statuscolumn = '%#SignColumn#%s%{v:lua.Ty.stl_foldlevel()}%{%v:lua.Ty.stl_num()%}'
  -- o.laststatus = 3 --- Have a global statusline at the bottom instead of one for each window
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
  o.formatoptions:remove('t')
  o.splitkeep = 'screen'
  o.lazyredraw = false --- Makes macros faster & prevent errors in complicated mappings
  if vim.fn.executable('rg') == 1 then
    -- credit: https://github.com/nicknisi/dotfiles/blob/1360edda1bbb39168637d0dff13dd12c2a23d095/config/nvim/init.lua#L73
    -- if ripgrep installed, use that as a grepper
    o.grepprg = 'rg --vimgrep --color=never --with-filename --line-number --no-heading --smart-case --'
    o.grepformat = '%f:%l:%c:%m,%f:%l:%m'
  end
  o.sessionoptions = { 'buffers', 'curdir', 'tabpages', 'winsize', 'help', 'globals', 'skiprtp', 'folds' }
end

function M.init_folds()
  if vim.g.vscode then
    return
  end
  o.foldnestmax = 10 -- deepest fold is 10 levels
  o.foldlevel = 99 --- Using ufo provider need a large value
  o.foldlevelstart = 99 --- Expand all folds by default
end

function M.init_other()
  g.python3_host_prog = vim.cfg.runtime__python3_host_prog
  local has_py = g.python3_host_prog ~= nil and vim.fn.executable(g.python3_host_prog) == 1
  if not has_py and vim.fn.executable('/usr/local/bin/python3') == 1 then
    vim.g.python3_host_prog = '/usr/local/bin/python3'
  elseif not has_py and vim.fn.executable('/usr/bin/python3') == 1 then
    vim.g.python3_host_prog = '/usr/bin/python3'
  end
  g.node_host_prog = '$HOME/.nix-profile/bin/neovim-node-host'

  -- Fix markdown indentation settings
  g.markdown_recommended_style = 0

  -- built-in plugins disable.
  for _, plugin in ipairs(vim.cfg.runtime__disable_builtin_plugins) do
    local var = 'loaded_' .. plugin
    vim.g[var] = 1
  end
  -- built-in neovim RPC provider disable
  for _, provider in ipairs(vim.cfg.runtime__disable_builtin_provider) do
    local var = 'loaded_' .. provider .. '_provider'
    vim.g[var] = 0
  end
end

--- called by statusline component on load.
function M.setup_statusline()
  vim.opt.laststatus = 2 --- Have a global statusline at the bottom instead of one for each window
  if vim.cfg.runtime__starts_as_gittool then
    vim.opt.laststatus = 2
    vim.opt.statusline = [[%<%n#%f %q%h%m%r[%{v:lua.Ty.stl_git_three_way_name()}]%=%-14.(%l,%c%V%)%p%% %y %w]]
  end
  -- in nvim-tree or windows picker, the laststatus will be modified
end

--- need to lazy setup, otherwise bunch mods needed to be load.
function M.setup_lsp()
  if vim.cfg.lsp__log_level then
    vim.lsp.set_log_level(vim.cfg.lsp__log_level)
  end
end

function M.setup()
  M.init_interface()
  M.init_other()
  M.init_folds()
  M.setup_statusline()

  if vim.g.vscode then
    return
  end

  local ftau = vim.api.nvim_create_augroup('option_ft', { clear = true })
  vim.api.nvim_create_autocmd('BufReadPost', {
    group = ftau,
    callback = vim.schedule_wrap(function(args)
      local buf = args.buf
      --- is invalid when rename folders etc
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      local ft = vim.bo[buf].filetype
      if not ft or ft == '' then
        return
      end
      -- NOTE: nvim-treesitter on comment have some bugs.
      if ft == 'comment' or vim.g.vscode then
        return
      end
      if vim.cfg.runtime__starts_as_gittool then
        return
      end

      if vim.b[buf].treesitter_disable == true or vim.bo.buftype ~= '' then
        return
      end
      if not vim.api.nvim_buf_is_valid(buf) then
        return
      end
      local is_big_file = vim.b[buf].is_big_file
      local Buffer = require('userlib.runtime.buffer')
      if is_big_file or (is_big_file == nil and Buffer.is_big_file(buf, {
        size = 1024 * 100,
      })) then
        return
      end
      -- start highlighter.
      local ok, err = pcall(vim.treesitter.start, buf)
      if not ok then
        -- vim.notify(err, vim.log.levels.ERROR)
        return
      end
      require('userlib.runtime.au').exec_useraucmd('TreeSitterStart', {
        data = {
          bufnr = buf,
        },
      })
    end),
  })
end

return M
