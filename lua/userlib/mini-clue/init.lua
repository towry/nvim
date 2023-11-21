local M = {}

M.shortly_prefix = '<leader>z+'
local keys_mode = {}

---@param fn function
M.shortly_open = function(fn)
  local buf = vim.api.nvim_get_current_buf()

  local clues = {}

  local bufset = require('userlib.runtime.keymap').map_buf_thunk(buf)
  local set = function(...)
    local args = { ... }
    local mode = args[1]
    local key = args[2]
    local command = args[3]
    local opts = args[4] or {}
    table.insert(clues, { mode = mode, keys = M.shortly_prefix .. key, desc = opts.desc })
    if type(mode == 'string') then
      mode = { mode }
    end
    --- record keys with mode to be deleted later
    for _, m in ipairs(mode) do
      keys_mode[m] = keys_mode[m] or {}
      table.insert(keys_mode[m], key)
    end
    local keys = M.shortly_prefix .. key
    bufset(mode, keys, command, opts)
  end
  local unset = function()
    --- use vim.api.nvim_buf_del_keymap to delete previously set keys
    for mode, keys in pairs(keys_mode) do
      for _, key in ipairs(keys) do
        vim.api.nvim_buf_del_keymap(buf, mode, M.shortly_prefix .. key)
      end
    end
    keys_mode = {}
  end

  fn(set, unset, buf)

  vim.b[buf].miniclue_config = {
    clues = clues,
    window = {
      delay = 30,
    }
  }
  vim.schedule(function()
    require('mini.clue').ensure_buf_triggers(buf)
    M.show_on_keys(M.shortly_prefix)
  end)
end

M.show_on_keys = function(keys)
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), 'mit', false)
end

return M
