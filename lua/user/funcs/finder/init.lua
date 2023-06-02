
local M = {}

--- nvim-tree
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
function M.nvim_tree_find_file() run_nvim_tree_toggle_cmd('NvimTreeFindFile') end


return M