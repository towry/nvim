local M = {}

function M.setup_commands(client, bufnr)
  local buf_command = require('userlib.runtime.utils').buf_command_thunk(bufnr)

  buf_command('LspRename', function(opt)
    vim.lsp.buf.rename(opt.args ~= '' and opt.args or nil)
  end, { nargs = '?', desc = 'Rename the current symbol at the cursor.' })
end

return M
