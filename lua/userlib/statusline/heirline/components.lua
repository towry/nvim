-- local heirline = require('heirline')
local conditions = require('heirline.conditions')
local utils = require('heirline.utils')
local format_utils = require('userlib.lsp.servers.null_ls.fmt')
local auto_format_disabled = require('userlib.lsp.servers.null_ls.autoformat').disabled

local Spacer = { provider = ' ' }
local function rpad(child)
  child = child or {}
  return {
    condition = child.condition,
    child,
    Spacer,
  }
end
local function lpad(child)
  child = child or {}
  return {
    condition = child.condition,
    Spacer,
    child,
  }
end

local stl_static = {
  mode_color_map = {
    n = 'function',
    i = 'green',
    v = 'statement',
    V = 'statement',
    ['\22'] = 'statement',
    c = 'black',
    s = 'statement',
    S = 'statement',
    ['\19'] = 'statement',
    R = 'red',
    r = 'red',
    ['!'] = 'constant',
    t = 'constant',
  },
  mode_color = function(self)
    local mode = vim.fn.mode():sub(1, 1) -- get only the first mode character
    return self.mode_color_map[mode]
  end,
}

local ViMode = {
  init = function(self)
    self.mode = vim.fn.mode() -- :h mode()

    -- execute this only once, this is required if you want the ViMode
    -- component to be updated on operator pending mode
    if not self.once then
      vim.api.nvim_create_autocmd('ModeChanged', {
        pattern = '*:*o',
        command = 'redrawstatus',
      })
      self.once = true
    end
  end,
  -- Now we define some dictionaries to map the output of mode() to the
  -- corresponding string and color. We can put these into `static` to compute
  -- them at initialisation time.
  static = {
    mode_names = {
      n = 'NOR',
      no = 'NOR-',
      nov = 'NOR-',
      noV = 'NOR-',
      ['no\22'] = 'NOR-',
      niI = 'NOR-',
      niR = 'NOR-',
      niV = 'NOR-',
      nt = 'NOR-',
      v = 'VIS',
      vs = 'VIS-',
      V = 'V-LINE',
      Vs = 'V-LINE-',
      ['\22'] = 'V-BLOCK',
      ['\22s'] = 'V-BLOCK-',
      s = 'SELECT',
      S = 'S-LINE',
      ['\19'] = 'S-BLOCK',
      i = 'INS',
      ic = 'INS-',
      ix = 'INS-',
      R = 'REP',
      Rc = 'REP-',
      Rx = 'REP-',
      Rv = 'REP-',
      Rvc = 'REP-',
      Rvx = 'REP-',
      c = 'CMD',
      cv = 'CMD-',
      r = 'PROMPT',
      rm = 'MORE',
      ['r?'] = 'CONFIRM',
      ['!'] = 'SHELL',
      t = 'TERM',
    },
  },
  provider = function(self)
    return ' ' .. self.mode_names[self.mode] .. ' '
  end,
  hl = function(self)
    return { bg = self:mode_color(), fg = 'white', bold = true }
  end,
  update = {
    'ModeChanged',
  },
}

local FileIcon = {
  init = function(self)
    -- not working
    self.icon, self.icon_color =
      require('nvim-web-devicons').get_icon_color_by_filetype(vim.bo[self.bufnr or 0].filetype, { default = true })
  end,
  provider = function(self)
    return self.icon and (self.icon .. ' ')
  end,
  hl = function(self)
    return { fg = self.icon_color }
  end,
}

local FileType = {
  condition = function()
    return vim.bo.filetype ~= ''
  end,
  FileIcon,
  {
    provider = function()
      local ft = vim.bo.filetype
      if #ft > 4 then
        -- pick first two and last one
        ft = ft:sub(1, 2) .. '~' .. ft:sub(#ft, #ft)
        return ft
      end
      return ft
    end,
  },
}

local FileName = {
  provider = function()
    local filename = vim.b.relative_path or vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ':.')
    if filename == '' then
      return '[No Name]'
    end
    -- now, if the filename would occupy more than 90% of the available
    -- space, we trim the file path to its initials
    if not conditions.width_percent_below(#filename, 0.90) then
      filename = vim.fn.pathshorten(filename)
    end
    return filename
  end,
}

local BufferCwd = {
  init = function(self)
    self.bufnr = self.bufnr or 0
  end,
  provider = function(self)
    local cwd = vim.fn.fnamemodify(vim.b[self.bufnr].project_nvim_cwd or vim.uv.cwd() or '', ':t')
    if not cwd or cwd == '' then
      return ''
    end

    return ' ' .. cwd
  end,
}

local FileFlags = {
  {
    condition = function()
      return vim.bo.modified
    end,
    provider = ' [+]',
  },
  {
    condition = function()
      return not vim.bo.modifiable or vim.bo.readonly
    end,
    provider = ' ',
  },
}

local GitStatus = {
  condition = function()
    if not vim.b.gitsigns_status_dict then
      return false
    end
    local status = vim.b.gitsigns_status_dict
    return status.added ~= 0 or status.removed ~= 0 or status.changed ~= 0
  end,
  init = function(self)
    self.status_dict = vim.b.gitsigns_status_dict
    if self.status_dict == nil then
      self.has_changes = false
      return
    end
    self.has_changes = self.status_dict ~= nil and self.status_dict.added ~= 0
      or self.status_dict.removed ~= 0
      or self.status_dict.changed ~= 0
  end,

  hl = { fg = utils.get_highlight('Constant').fg },
  {
    provider = function(self)
      local count = self.status_dict.added or 0
      return count > 0 and ('+' .. count) or ''
    end,
    hl = { fg = utils.get_highlight('DiffAdd').fg },
  },
  {
    provider = function(self)
      local count = self.status_dict.changed or 0
      return count > 0 and ('~' .. count) or ''
    end,
    hl = { fg = utils.get_highlight('DiffChange').fg },
  },
  {
    provider = function(self)
      local count = self.status_dict.removed or 0
      return count > 0 and ('-' .. count) or ''
    end,
    hl = { fg = utils.get_highlight('DiffDelete').fg },
  },
}

local FullFileName = {
  hl = function()
    local fg
    if vim.bo.modified then
      fg = 'yellow'
    else
      fg = conditions.is_active() and 'winbar_fg' or 'winbar_nc_fg'
    end
    return {
      fg = fg,
      bg = conditions.is_active() and 'winbar_bg' or 'winbar_nc_bg',
    }
  end,
  FileName,
  FileFlags,
  { provider = '%=' },
}

local DirAndFileName = {
  hl = function()
    local fg
    if vim.bo.modified then
      fg = 'yellow'
    else
      fg = conditions.is_active() and 'winbar_fg' or 'winbar_nc_fg'
    end
    return {
      fg = fg,
      bg = conditions.is_active() and 'winbar_bg' or 'winbar_nc_bg',
    }
  end,
  -- lpad(BufferCwd),
  FileIcon,
  lpad(FileName),
  { provider = '#%1.3n.%{tabpagewinnr(tabpagenr())}' },
  FileFlags,
  { provider = '%=' },
}

local function OverseerTasksForStatus(status)
  return {
    condition = function(self)
      return self.tasks[status]
    end,
    provider = function(self)
      if #self.tasks[status] <= 0 then
        return ''
      end
      return string.format('%s%d', self.symbols[status], #self.tasks[status])
    end,
    hl = function()
      return {
        fg = utils.get_highlight(string.format('Overseer%s', status)).fg,
      }
    end,
  }
end
local Overseer = {
  condition = function()
    return package.loaded.overseer
  end,
  init = function(self)
    local tasks = require('overseer.task_list').list_tasks({ unique = true })
    local tasks_by_status = require('overseer.util').tbl_group_by(tasks, 'status')
    self.tasks = tasks_by_status
  end,
  static = {
    symbols = {
      ['CANCELED'] = ' ',
      ['FAILURE'] = '󰅚 ',
      ['SUCCESS'] = '󰄴 ',
      ['RUNNING'] = '󰑮 ',
    },
  },

  OverseerTasksForStatus('CANCELED'),
  OverseerTasksForStatus('RUNNING'),
  OverseerTasksForStatus('SUCCESS'),
  OverseerTasksForStatus('FAILURE'),
}

local function setup_colors()
  return {
    fg = utils.get_highlight('StatusLine').fg or 'none',
    bg = utils.get_highlight('StatusLine').bg or 'none',
    winbar_fg = utils.get_highlight('Winbar').fg or 'none',
    winbar_bg = utils.get_highlight('Winbar').bg or 'none',
    winbar_nc_fg = utils.get_highlight('WinbarNC').fg or 'none',
    winbar_nc_bg = utils.get_highlight('WinbarNC').bg or 'none',
    tablinesel_fg = utils.get_highlight('TabLineSel').fg or 'none',
    tablinesel_bg = utils.get_highlight('TabLineSel').bg or 'none',
    tabline_fg = utils.get_highlight('TabLine').fg or 'none',
    tabline_bg = utils.get_highlight('TabLine').bg or 'none',
    red = utils.get_highlight('DiagnosticError').fg or 'none',
    yellow = utils.get_highlight('DiagnosticWarn').fg or 'none',
    green = utils.get_highlight('DiagnosticOk').fg or 'none',
    gray = utils.get_highlight('NonText').fg or 'none',
    ['function'] = utils.get_highlight('Function').fg or 'none',
    constant = utils.get_highlight('Constant').fg or 'none',
    statement = utils.get_highlight('Statement').fg or 'none',
    visual = utils.get_highlight('Visual').bg or 'none',
    diag_warn = utils.get_highlight('DiagnosticWarn').fg or 'none',
    diag_error = utils.get_highlight('DiagnosticError').fg or 'none',
  }
end

local ArduinoStatus = {
  condition = function()
    return vim.bo.filetype == 'arduino'
  end,
  provider = function()
    local port = vim.fn['arduino#GetPort']()
    local line = string.format('[%s]', vim.g.arduino_board)
    if vim.g.arduino_programmer ~= '' then
      line = line .. string.format(' [%s]', vim.g.arduino_programmer)
    end
    if port ~= 0 then
      line = line .. string.format(' (%s:%s)', port, vim.g.arduino_serial_baud)
    end
    return line
  end,
}

-- HACK I don't know why, but the stock implementation of lsp_attached is causing error output
-- (UNKNOWN PLUGIN): Error executing lua: attempt to call a nil value
-- It gets written to raw stderr, which then messes up all of vim's rendering. It's something to do
-- with the require("vim.lsp") call deep in the vim metatable __index function. I don't know the
-- root cause, but I'm done debugging this for today.
conditions.lsp_attached = function()
  return next(vim.lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })) ~= nil
end

local LSPActive = {
  update = { 'LspAttach', 'LspDetach', 'VimResized', 'FileType', 'BufEnter', 'BufWritePost' },

  flexible = 1,
  {
    provider = function()
      local names = {}
      local lsp = vim.lsp
      if lsp then
        for _, server in pairs(lsp.get_clients({ bufnr = vim.api.nvim_get_current_buf() })) do
          table.insert(names, server.name)
        end
      end
      local lint = package.loaded.lint
      if lint and vim.bo.buftype == '' then
        table.insert(names, '⫽')
        for _, linter in ipairs(lint.linters_by_ft[vim.bo.filetype] or {}) do
          table.insert(names, linter)
        end
      end
      local conform = package.loaded.conform
      if conform and vim.bo.buftype == '' then
        local formatters = conform.list_formatters(0)
        if not conform.will_fallback_lsp() then
          table.insert(names, '⫽')
          for _, formatter in ipairs(formatters) do
            table.insert(names, formatter.name)
          end
        end
      end
      if vim.tbl_isempty(names) then
        return ''
      else
        return ' [' .. table.concat(names, ' ') .. ']'
      end
    end,
  },
  {
    condition = conditions.lsp_attached,
    provider = ' [LSP]',
  },
  {
    condition = conditions.lsp_attached,
    provider = ' ',
  },
}

local Ruler = {
  provider = ' %P %l:%c ',
  hl = function(self)
    return { fg = 'black', bg = self:mode_color(), bold = true }
  end,
}

local Branch = {
  condition = function()
    return vim.fn.exists('*FugitiveHead') == 1
  end,
  init = function(self)
    if vim.fn.exists('*FugitiveHead') then
      self.head = vim.fn['FugitiveHead']()
    else
      self.head = ''
    end
  end,
  provider = function(self)
    return self.head ~= '' and ' ' .. (self.head or '')
  end,
  update = {
    'User',
    -- doesn't work if current dir is changed
    pattern = { 'FugitiveChanged', 'FugitiveIndex', 'FugitiveObject' },
  },
}

local Harpoon = {
  condition = function()
    local loaded = package.loaded.harpoon
    if not loaded then
      return false
    end
    return true
  end,
  init = function(self)
    self.harpoon_idx = require('harpoon.mark').status()
  end,
  provider = function(self)
    if not self.harpoon_idx or self.harpoon_idx == '' then
      return ''
    end
    return ' ' .. self.harpoon_idx
  end,
  hl = function()
    return {
      fg = 'red',
    }
  end,
}

local ProfileRecording = {
  condition = function()
    local profile = package.loaded.profile
    return profile and profile.is_recording()
  end,
  provider = function()
    return '󰑊 '
  end,
  hl = function()
    return { fg = 'red' }
  end,
  update = {
    'User',
    pattern = { 'ProfileStart', 'ProfileStop' },
  },
}

local DiagnosticsDisabled = {
  condition = function()
    return vim.diagnostic.is_disabled()
  end,
  provider = function()
    return ' '
  end,
}

local WorkspaceRoot = {
  condition = function()
    return vim.cfg.runtime__starts_cwd_short ~= nil
  end,
  provider = function()
    return ' ' .. vim.cfg.runtime__starts_cwd_short
  end,
}

local Tabs = {
  condition = function()
    return #vim.api.nvim_list_tabpages() >= 2
  end, -- only show tabs if there are more than one
  utils.make_tablist({ -- component for each tab
    provider = function(self)
      return (self and self.tabnr) and '%' .. self.tabnr .. 'T ' .. self.tabnr .. ' %T' or ''
    end,
    hl = function(self)
      if not self.is_active then
        return { fg = 'tabline_fg', bg = 'tabline_bg' }
      else
        return { fg = 'tablinesel_fg', bg = 'tablinesel_bg' }
      end
    end,
  }),
  update = { 'VimEnter', 'TabNew', 'TabLeave' },
}

local LspFormatter = {
  init = function(self)
    local ftr_name, impl_ftr_name = format_utils.current_formatter_name(0)
    self.formatter_icon = '󰎟 '
    self.formatter_disable_icon = '󰙧 '
    self.formatter_name = impl_ftr_name or ftr_name or ''
    self.disabled = auto_format_disabled(0)
  end,
  provider = function(self)
    if self.formatter_name == '' then
      return ''
    end
    if self.disabled then
      return self.formatter_disable_icon
    end
    return string.format('%s%s', self.formatter_icon, self.formatter_name)
  end,
  update = { 'User', pattern = 'StatuslineUpdate' },
}

local Dap = {
  condition = function()
    if package.loaded.dap == nil then
      return false
    end
    local session = require('dap').session()
    return session ~= nil
  end,
  provider = function()
    return ' ' .. require('dap').status()
  end,
  hl = 'Debug',
}

local Codeium = {
  condition = function()
    return vim.fn.exists('*codeium#GetStatusString') == 1
  end,
  {
    provider = function()
      local str = vim.api.nvim_call_function('codeium#GetStatusString', {})
      str = vim.trim(str)
      if str == '' or str == 0 then
        str = '-'
      end
      return '{C:' .. str .. '}'
    end,
  },
}

local Copilot = {
  condition = function()
    return vim.g.loaded_copilot == 1
  end,
  init = function(self)
    self.enable = self.get_status() == 1
  end,
  static = {
    running = false,
    count = -1,
    -- if this comes to 0, means no running finally.
    timer = nil,
    spin = '',
    get_status = function()
      if vim.g.loaded_copilot == 1 and vim.g.copilot_enabled ~= 0 then
        return 1
      else
        return 0
      end
    end,
    is_running = function()
      return vim.g.copilot_status == 'pending'
    end,
  },
  provider = function(self)
    if not self.enable then
      return '󱚧 '
    end
    if not self.is_running() then
      return '󰚩 '
    end
    return '󰆄 '
  end,
  hl = function(self)
    local fg = vim.g.copilot_auto_mode == true and 'orange' or ''
    if self.is_running() then
      fg = 'green'
    end
    return {
      fg = fg,
    }
  end,
  update = {
    'User',
    pattern = 'CopilotStatus',
    callback = vim.schedule_wrap(function()
      vim.cmd.redrawstatus()
    end),
  },
}

local TerminalName = {
  -- we could add a condition to check that buftype == 'terminal'
  -- or we could do that later (see #conditional-statuslines below)
  provider = function()
    local tname, _ = vim.api.nvim_buf_get_name(0):gsub('.*:', '')
    -- remove '/usr/local/bin/fish;' part from tname
    tname, _ = tname:gsub('.*;', '')
    return ' ' .. tname
  end,
  hl = { fg = 'blue', bold = true },
}

local HelpFileName = {
  condition = function()
    return vim.bo.filetype == 'help'
  end,
  provider = function()
    local filename = vim.api.nvim_buf_get_name(0)
    return vim.fn.fnamemodify(filename, ':t')
  end,
  hl = { fg = 'blue' },
}

local TerminalStatusline = {
  condition = function()
    return conditions.buffer_matches({ buftype = { 'terminal' } })
  end,
  { TerminalName },
}

local NavigateDirection = {
  condition = function()
    return vim.g.direction ~= nil
  end,
  provider = function()
    return ({
      next = '[NEXT]',
      prev = '[PRE]',
    })[vim.g.direction]
  end,
}

local LastExCommand = {
  provider = function()
    local res = vim.fn.getreg(':')
    if not res or res == '' then
      return ''
    end
    res = vim.fn.strcharpart(res, 0, 20)
    return '[' .. res .. ']'
  end,
}

local gitinfo = require('userlib.git.gitinfo')
local Gitinfo = {
  condition = function()
    return vim.fn.exists('*FugitiveHead') == 1
      and (gitinfo.gitinfo.dirty > 0 or gitinfo.gitinfo.aheads > 0 or gitinfo.gitinfo.behinds > 0)
  end,
  {
    provider = '[',
  },
  {
    provider = function()
      local dirty = gitinfo.gitinfo.dirty
      if dirty > 0 then
        return string.format('*%d', dirty)
      end
      return ''
    end,
    hl = { fg = utils.get_highlight('DiffChange').fg, bg = utils.get_highlight('DiffChange').bg },
  },
  -- aheads
  {
    provider = function()
      local aheads = gitinfo.gitinfo.aheads
      if aheads > 0 then
        return string.format('↑%d', aheads)
      end
      return ''
    end,
    hl = { fg = utils.get_highlight('DiffChange').fg, bg = utils.get_highlight('DiffChange').bg },
  },
  -- behinds
  {
    provider = function()
      local behinds = gitinfo.gitinfo.behinds
      if behinds > 0 then
        return string.format('↓%d', behinds)
      end
      return ''
    end,
    hl = { fg = utils.get_highlight('DiffChange').fg, bg = utils.get_highlight('DiffChange').bg },
  },
  {
    provider = ']',
  },
}

local BufVisited = {
  condition = function()
    return package.loaded['mini.visits'] ~= nil
  end,
  init = function(self)
    local is = require('userlib.mini.visits').is_buf_harpoon(0)
    self.is = is
  end,
  provider = function(self)
    local is = self.is
    if is then
      return '[Harpoon]'
    end
    return ''
  end,
}

----- tabline
local Tabpage = {
  provider = function(self)
    return '%' .. self.tabnr .. 'T ' .. self.tabpage .. ' %T'
  end,
  hl = function(self)
    if not self.is_active then
      return 'TabLine'
    else
      return 'TabLineSel'
    end
  end,
}

local TablineBufnr = {
  provider = function(self)
    return tostring(self.bufnr) .. '. '
  end,
  hl = 'Comment',
}

-- we redefine the filename component, as we probably only want the tail and not the relative path
local TablineFileName = {
  provider = function(self)
    -- self.filename will be defined later, just keep looking at the example!
    local filename = self.filename
    filename = vim.fn.fnamemodify(vim.b[self.bufnr].relative_path or filename, ':~.')
    -- handle oil buf etc
    if vim.bo[self.bufnr].buftype ~= '' then
      return filename == '' and '[No Name]' or filename
    end
    filename = filename == '' and '[No Name]' or filename
    return filename
  end,
  hl = function(self)
    return { bold = self.is_active or self.is_visible, italic = true }
  end,
}

-- this looks exactly like the FileFlags component that we saw in
-- #crash-course-part-ii-filename-and-friends, but we are indexing the bufnr explicitly
-- also, we are adding a nice icon for terminal buffers.
local TablineFileFlags = {
  {
    condition = function(self)
      return vim.api.nvim_get_option_value('modified', { buf = self.bufnr })
    end,
    provider = '[+]',
    hl = { fg = 'green' },
  },
  {
    condition = function(self)
      return not vim.api.nvim_get_option_value('modifiable', { buf = self.bufnr })
        or vim.api.nvim_get_option_value('readonly', { buf = self.bufnr })
    end,
    provider = function(self)
      if vim.api.nvim_get_option_value('buftype', {
        buf = self.bufnr,
      }) == 'terminal' then
        return '  '
      else
        return ''
      end
    end,
    hl = { fg = 'orange' },
  },
}

-- Here the filename block finally comes together
local TablineFileNameBlock = {
  init = function(self)
    self.filename = vim.api.nvim_buf_get_name(self.bufnr)
  end,
  hl = function(self)
    if self.is_active then
      return 'TabLineSel'
      -- why not?
      -- elseif not vim.api.nvim_buf_is_loaded(self.bufnr) then
      --     return { fg = "gray" }
    else
      return 'TabLine'
    end
  end,
  on_click = {
    callback = function(_, minwid, _, button)
      if button == 'm' then -- close on mouse middle click
        vim.schedule(function()
          vim.api.nvim_buf_delete(minwid, { force = false })
        end)
      else
        vim.api.nvim_win_set_buf(0, minwid)
      end
    end,
    minwid = function(self)
      return self.bufnr
    end,
    name = 'heirline_tabline_buffer_callback',
  },
  TablineBufnr,
  TablineFileName,
  TablineFileFlags,
}

-- The final touch!
local TablineBufferBlock = utils.surround({ '█', '█' }, function(self)
  if self.is_active then
    return utils.get_highlight('TabLineSel').bg
  else
    return utils.get_highlight('TabLine').bg
  end
end, { TablineFileNameBlock })

local TablineBufferLine = utils.make_buflist(
  TablineBufferBlock,
  { provider = ' ', hl = { fg = 'gray' } },
  { provider = ' ', hl = { fg = 'gray' } },
  -- out buf_func simply returns the buflist_cache
  function()
    return { vim.api.nvim_get_current_buf() }
    -- return require('userlib.runtime.buffer').list_tab_buffers()
  end,
  false
)

local TabPages = {
  -- only show this component if there's 2 or more tabpages
  condition = function()
    return #vim.api.nvim_list_tabpages() >= 2
  end,
  utils.make_tablist(Tabpage),
  {
    provider = '┃',
    hl = {
      bg = utils.get_highlight('TabLine').bg,
      fg = utils.get_highlight('TabLineSel').fg,
    },
  },
}

local TabLine = {
  TabPages,
  {
    rpad(lpad(BufferCwd)),
    hl = 'TabLine',
  },
  -- TablineBufferLine,
  { provider = '%=' },
}

return {
  TerminalStatusline = TerminalStatusline,
  HelpFileName = HelpFileName,
  ViMode = ViMode,
  Ruler = Ruler,
  Spacer = Spacer,
  rpad = rpad,
  lpad = lpad,
  FileIcon = FileIcon,
  FileType = FileType,
  FullFileName = FullFileName,
  Overseer = Overseer,
  setup_colors = setup_colors,
  -- SessionName = SessionName,
  ArduinoStatus = ArduinoStatus,
  LSPActive = LSPActive,
  stl_static = stl_static,
  -- ConjoinStatus = ConjoinStatus,
  ProfileRecording = ProfileRecording,
  Branch = Branch,
  GitStatus = GitStatus,
  Harpoon = Harpoon,
  DirAndFileName = DirAndFileName,
  DiagnosticsDisabled = DiagnosticsDisabled,
  WorkspaceRoot = WorkspaceRoot,
  LspFormatter = LspFormatter,
  Tabs = Tabs,
  Copilot = Copilot,
  Dap = Dap,
  NavigateDirection = NavigateDirection,
  LastExCommand = LastExCommand,
  Codeium = Codeium,
  Gitinfo = Gitinfo,
  BufVisited = BufVisited,
  TabLine = TabLine,
}
