-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

local v = require('v')

do -- smart close
  local function smart_close()
    if vim.fn.winnr('$') ~= 1 then
      vim.api.nvim_win_close(0, true)
    end
  end
  local smart_close_ft = v.util_mk_pattern_table({
    ['help'] = true,
    ['qf'] = true,
    ['log'] = true,
    ['query'] = true,
    ['dbui'] = true,
    ['lspinfo'] = true,
    ['git.*'] = true,
    ['Neogit.*'] = true,
    ['neotest.*'] = true,
    ['fugitive.*'] = true,
    ['copilot.*'] = true,
    ['startuptime'] = true,
  })
  local smart_close_buftypes = v.util_mk_pattern_table({
    nofile = true,
  })
  v.nvim_augroup('SmartWinClose', {
    event = 'FileType',
    command = function(event)
      local is_unmapped = not v.nvim_has_keymap('q', 'n')
      local buftype = vim.bo[event.buf].buftype
      local filetype = vim.bo[event.buf].filetype
      local is_eligible = is_unmapped
        or vim.wo.previewwindow
        or smart_close_buftypes[buftype]
        or smart_close_ft[filetype]

      if not is_eligible then
        return
      end
      vim.bo[event.buf].buflisted = false
      vim.keymap.set('n', 'q', smart_close, { buffer = event.buf, silent = true, nowait = true })
    end,
  }, {
    event = { 'BufEnter' },
    command = function()
      if vim.fn.winnr('$') == 1 and vim.bo.buftype == 'quickfix' then
        vim.api.nvim_buf_delete(0, { force = true })
      end
    end,
    desc = 'Close quickfix window if the file containing it was closed',
  }, {
    event = { 'QuitPre' },
    nested = true,
    command = function()
      if vim.bo.filetype ~= 'qf' then
        vim.cmd.lclose({ mods = { silent = true } })
      end
    end,
    desc = 'Auto close corresponding loclist when quiting a window',
  })
end

v.nvim_augroup('GrepWinAutoOpen', {
  event = { 'QuickFixCmdPost' },
  pattern = { '*grep*' },
  command = 'cwindow',
})
v.nvim_augroup('CheckOutsideChange', {
  event = { 'WinEnter', 'BufWinEnter', 'BufWinLeave', 'BufRead', 'BufEnter', 'FocusGained' },
  command = 'silent! checktime',
})
v.nvim_augroup('TerminalAutocommands', {
  event = { 'TermClose' },
  command = function(args)
    --- automatically close a terminal if the job was successful
    if v.util_falsy(vim.v.event.status) and v.util_falsy(vim.bo[args.buf].ft) then
      vim.cmd.bdelete({ args.buf, bang = true })
    end
  end,
})
