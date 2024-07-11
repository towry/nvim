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
}, {
  event = { 'TermRequest' },
  desc = 'Update cwd from terminal',
  command = function(ev)
    if string.sub(vim.v.termrequest, 1, 4) == '\x1b]7;' then
      local dir = string.gsub(vim.v.termrequest, '\x1b]7;file://[^/]*', '')
      if vim.fn.isdirectory(dir) == 0 then
        vim.notify('invalid dir: ' .. dir)
        return
      end
      vim.api.nvim_buf_set_var(ev.buf, 'osc7_dir', dir)
      if vim.o.autochdir and vim.api.nvim_get_current_buf() == ev.buf then
        vim.cmd.cd(dir)
      end
    end
  end,
}, {
  event = { 'TermOpen' },
  pattern = 'term://*',
  command = vim.schedule_wrap(function(ctx)
    if vim.api.nvim_get_current_buf() ~= ctx.buf then
      -- Overseer will open term, and close shortly.
      return
    end
    vim.cmd.setlocal('sidescrolloff=0')
    vim.cmd('startinsert')
    if vim.g.set_terminal_keymaps then
      vim.g.set_terminal_keymaps(ctx.buf)
    end
  end),
})
v.nvim_augroup('SetKeyOnCmdWin', {
  event = { 'CmdwinEnter' },
  command = function(ctx)
    local bufnr = ctx.buf
    assert(type(bufnr) == 'number')
    vim.b[bufnr].bufname = 'Cmdwin'
    local set = vim.keymap.set

    --- run command and reopen it
    set('n', '<F1>', '<CR>q:', {
      buffer = bufnr,
      silent = true,
    })
    set('n', 'q', '<C-w>c', {
      buffer = bufnr,
      silent = true,
      nowait = true,
      noremap = true,
    })
  end
})
v.nvim_augroup("bigfile", {
  event = { 'FileType' },
  pattern = 'bigfile',
  command = function(ev)
    vim.b.minianimate_disable = true
    vim.schedule(function()
      vim.bo[ev.buf].syntax = vim.filetype.match({ buf = ev.buf }) or ""
    end)
  end,
})
--- should be called as soon as possible.
vim.g.setup_lazy_events = function()
  -- This autocmd will only trigger when a file was loaded from the cmdline.
  -- It will render the file as quickly as possible.
  vim.api.nvim_create_autocmd("BufReadPost", {
    once = true,
    callback = function(event)
      -- Skip if we already entered vim
      if vim.v.vim_did_enter == 1 then
        return
      end

      -- Try to guess the filetype (may change later on during Neovim startup)
      local ft = vim.filetype.match({ buf = event.buf })
      if ft then
        -- Add treesitter highlights and fallback to syntax
        local lang = vim.treesitter.language.get_lang(ft)
        if not (lang and pcall(vim.treesitter.start, event.buf, lang)) then
          vim.bo[event.buf].syntax = ft
        end

        -- Trigger early redraw
        vim.cmd([[redraw]])
      end
    end,
  })
  local ok, Event = pcall(require, 'lazy.core.handler.event')
  if not ok then return end
  Event.mappings.LazyFile = { id = "LazyFile", event = { "BufReadPost", "BufNewFile", "BufWritePre" } }
  Event.mappings["User LazyFile"] = Event.mappings.LazyFile
end
