local Buffer = require('ty.core.buffer')
local M = {}

local tig_instance = nil

local function get_tig_term()
  if tig_instance then return tig_instance end
  local Terminal = require('toggleterm.terminal').Terminal
  local tig_     = Terminal:new({
    cmd = "tig",
    dir = "git_dir",
    direction = "float",
    hidden = true,
    float_opts = {
      border = "double",
    },
    -- function to run on opening the terminal
    on_open = function(term)
      vim.cmd("startinsert!")
      vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
    end,
    -- function to run on closing the terminal
    on_close = function(term)
      vim.cmd("startinsert!")
    end,
  })
  tig_instance   = tig_
  return tig_instance
end

M.toggle_tig = function()
  local tig = get_tig_term()
  tig:toggle()
end

M.terms_count = function()
  local buffers = Buffer.list()
  local pattern = 'term://.*'
  local count = 0
  for _, bName in pairs(buffers) do
    if string.match(bName, pattern) ~= nil then
      count = count + 1
    end
  end

  return count
end

return M
