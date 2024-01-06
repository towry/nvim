local au = require('userlib.runtime.au')
local path = require('userlib.runtime.path')
local M = {}

function M.buffer_is_neogit_view(ft)
  return vim.tbl_contains({
    'NeogitStatus',
    -- "NeogitLogView",
  }, ft)
end

-- vim.g.something do not allow complext string index
local private_neogit_views = {}
--- toggle between current neogit view and previous buffer.
function M.toggle()
  local Buffer = require('userlib.runtime.buffer')
  local filetype = vim.bo.filetype
  local cwd = vim.uv.cwd()
  local cwd_str = path.serialize_path_by_sep(path.remove_path_last_separator(cwd))
  if M.buffer_is_neogit_view(filetype) then
    -- go to previous buf
    local previous_bufnr = vim.fn.bufnr('#')
    Buffer.set_current_buffer_focus(previous_bufnr)
  else
    -- go to neogit.
    local neogit_buf_id = private_neogit_views[cwd_str]
    if not neogit_buf_id then
      require('neogit').open({
        cwd = cwd,
        kind = 'tab',
      })
      vim.schedule(function()
        local buf = vim.api.nvim_get_current_buf()
        private_neogit_views[cwd_str] = buf
        au.define_autocmd('BufUnload', {
          group = 'neogit_view_exit',
          buffer = buf,
          callback = function()
            private_neogit_views[cwd_str] = nil
          end,
        })
      end)
    else
      Buffer.set_current_buffer_focus(neogit_buf_id)
    end
  end
end

return M
