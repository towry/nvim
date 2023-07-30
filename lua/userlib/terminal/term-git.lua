local utils = require('userlib.runtime.utils')
local M = {}

local tig_instance = nil
local tig_pool = {}


--- Tig on dir
local function get_tig_term()
  if tig_instance then return tig_instance end
  local Terminal = require('toggleterm.terminal').Terminal
  local git_dir  = utils.get_root({
    only_pattern = true,
    root_patterns = { '.git' },
    pattern_start_path = vim.fn.getcwd(),
  })
  local tig_     = Terminal:new({
    cmd = "tig",
    dir = git_dir,
    direction = "vertical",
    close_on_exit = true,
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

--- View current file history by using tig.
M.toggle_tig_file_history = function()
  local bufnr = vim.api.nvim_get_current_buf()
  local buftype = vim.api.nvim_get_option_value('buftype', {
    buf = bufnr
  })
  if buftype ~= '' then
    vim.notify("Can not get git info on current buffer", vim.log.levels.ERROR, {
      title = "Toggle Tig File History",
    })
    return
  end
  local tig = tig_pool[bufnr]
  if not tig then
    local Terminal  = require('toggleterm.terminal').Terminal
    local tig_      = Terminal:new({
      cmd = string.format("tig %s", vim.fn.expand("%")),
      direction = "vertical",
      close_on_exit = true,
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
    tig_pool[bufnr] = tig_
    tig             = tig_

    vim.api.nvim_create_autocmd("BufUnload", {
      group = vim.api.nvim_create_augroup("tig_file_his_" .. bufnr, { clear = true }),
      buffer = bufnr,
      callback = function()
        if tig_pool[bufnr] then
          tig_pool[bufnr]:close()
          tig_pool[bufnr] = nil
        end
      end,
    })
  end

  tig:toggle()
end

return M
