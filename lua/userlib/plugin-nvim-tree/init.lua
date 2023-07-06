local M = {}

local function run_nvim_tree_toggle_cmd(cmd)
  -- there will be error if we open tree on telescope prompt.
  -- https://neovim.io/doc/user/options.html#'buftype'
  -- local buftype = vim.api.nvim_buf_get_option(0, 'buftype')
  local buftype = vim.api.nvim_get_option_value('buftype', {
    buf = 0
  })
  if buftype == 'prompt' then
    Ty.NOTIFY('please close the current prompt')
    return
  end
  vim.cmd(cmd)
end
function M.toggle_nvim_tree() run_nvim_tree_toggle_cmd('NvimTreeToggle') end

function M.toggle_nvim_tree_find_file() run_nvim_tree_toggle_cmd('NvimTreeFindFileToggle') end

function M.nvim_tree_find_file_direct()
  local level_up = vim.v.count
  if level_up > 0 then
    local cwd = require('userlib.telescope.helpers').get_cwd_relative_to_buf(0, level_up, false)
    if cwd then
      local tree_api = require('nvim-tree.api')
      tree_api.tree.open({
        update_root = false,
        find_file = true,
        current_window = false,
      })
      tree_api.tree.change_root(cwd)
      return
    end
  end
  vim.cmd('NvimTreeFindFile')
end

M.nvim_tree_find_file = function(opts)
  opts = opts or {}
  local treeview = require('nvim-tree.view')
  local is_open = treeview.is_visible()
  if is_open and opts.fallback then
    -- close if is open.
    run_nvim_tree_toggle_cmd('NvimTreeClose')
    return
  end
  local buf = vim.api.nvim_get_current_buf()
  -- if current buf is empty or not normal buf, then just return.
  -- local buftype = vim.api.nvim_buf_get_option(buf, 'buftype')
  local buftype = vim.api.nvim_get_option_value("buftype", {
    buf = buf,
  })
  if buftype ~= "" and not opts.fallback then
    vim.notify("Not normal buffer, can't find file in nvim-tree.", vim.log.levels.ERROR)
    return
  elseif buftype ~= "" then
    M.toggle_nvim_tree()
    return
  end
  M.nvim_tree_find_file_direct()
end

return M
