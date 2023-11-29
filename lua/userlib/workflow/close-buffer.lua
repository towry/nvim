local M = {}

function M.close()
  local current_buf = vim.api.nvim_get_current_buf()
  local mb = require('mini.bufremove')
  local bufstack = require('window-bufstack.bufstack')
  local next_buf = bufstack.peek_bufstack(0, {
    -- skip current.
    skip = 1
  })
  --- buffer is displayed in other window.
  if #vim.fn.win_findbuf(vim.fn.bufnr('%')) > 1 then
    bufstack.pop()
  else
    bufstack.ignore_next()
    -- BufWinEnter will be triggered for next buf
    -- and the next buf maybe already in the stack.
    mb.delete(current_buf)
  end
  -- if not valid buf
  if next_buf and not vim.api.nvim_buf_is_valid(next_buf) then
    next_buf = nil
  end
  -- has current tab have more than 1 window?
  if not next_buf then
    local current_tab_windows_count = require('userlib.runtime.buffer').current_tab_windows_count()
    print(current_tab_windows_count)
    local tabs_count = vim.fn.tabpagenr('$')
    local bufers_count = #vim.fn.getbufinfo({ buflisted = 1 })
    if current_tab_windows_count > 1 then
      vim.cmd('q')
    elseif tabs_count > 1 then
      vim.cmd('q')
    elseif bufers_count > 1 then
      mb.delete(current_buf)
    else
      if require('userlib.runtime.buffer').is_empty_buffer(current_buf) then
        vim.cmd('q')
      else
        vim.cmd('enew')
      end
    end
  else
    -- doesn't trigger the BufWinEnter event.
    vim.api.nvim_win_set_buf(0, next_buf)
  end
end

return M
