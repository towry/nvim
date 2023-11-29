local M = {}

M.shortly_prefix = '<leader>z+'

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
    local keys = M.shortly_prefix .. key
    bufset(mode, keys, command, opts)
  end
  local is_unset = false
  --- actually this is not neccessary
  local unset = function()
    if is_unset then return end
    is_unset = true
    vim.b[buf].miniclue_config = {}
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

M.extend_clues = function(clues)
  -- vim.print(clues)
  -- vim.b.miniclue_config = vim.b.miniclue_config or {}
  -- vim.b.miniclue_config['clues'] = vim.b.miniclue_config['clues'] or {}
  -- vim.list_extend(vim.b.miniclue_config['clues'], clues)
end

return M
