local au = require('userlib.runtime.au')
local path = require('userlib.runtime.path')
local M = {}

function M.buffer_is_neogit_view(ft)
  return vim.tbl_contains({
    'NeogitStatus',
    -- "NeogitLogView",
  }, ft)
end

--- toggle between current neogit view and previous buffer.
function M.toggle()
  vim.g.private_neogit_views = vim.g.private_neogit_views or {}
  local Buffer = require('userlib.runtime.buffer')
  local filetype = vim.bo.filetype
  local cwd = path.remove_path_last_separator(vim.uv.cwd())
  if M.buffer_is_neogit_view(filetype) then
    -- go to previous buf
    local previous_bufnr = vim.fn.bufnr('#')
    Buffer.set_current_buffer_focus(previous_bufnr)
  else
    -- go to neogit.
    local neogit_buf_id = vim.g.private_neogit_views[cwd]
    if not neogit_buf_id then
      require('neogit').open({
        cwd = cwd,
        kind = 'tab',
      })
      vim.schedule(function()
        local buf = vim.api.nvim_get_current_buf()
        vim.g.private_neogit_views[cwd] = buf
        au.define_autocmd('BufUnload', {
          group = 'neogit_view_exit',
          buffer = buf,
          callback = function()
            vim.g.private_neogit_views[cwd] = nil
          end,
        })
      end)
    else
      Buffer.set_current_buffer_focus(neogit_buf_id)
    end
  end
end

return M
