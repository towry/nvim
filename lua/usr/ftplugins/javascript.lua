local M = {}

M.attach = function()
  if vim.b.is_big_file or vim.g.vscode then
    return
  end
  require('userlib.keymaps.neotest').attach()
  require('userlib.keymaps.dap').attach()
  if package.loaded['typescript-tools'] then
    require('typescript-tools.user_commands').setup_user_commands()
  end

  local set = require('userlib.runtime.keymap').map_buf_thunk(0)
  set('n', '<localleader>gm', function()
    local linenr = require('userlib.runtime.ts').get_first_import_statement_linenr({
      regex_tester = function(line)
        --- for js, test line contains `require(`
        return line:find('require%(') ~= nil
      end,
    })
    if linenr == nil then
      return
    end
    -- move cursor to linenr
    vim.cmd('' .. linenr)
  end, {
    desc = 'Go to imports',
  })
end

return M
