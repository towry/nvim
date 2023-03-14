local M = {}

-- when buffer enter a window, check if current buf that inside this window is nofile buftype.
-- if yes, then prevent new buffer from openning inside this window, open it in another visible window
-- or create a new split window then open inside it.
local function prevent_open_in_nofile_window()
  if vim.bo.buftype == 'nofile' then
    local win = vim.api.nvim_get_current_win()
    local l = vim.api.nvim_list_wins()
    local is_set = false
    for _, v in ipairs(l) do
      if v ~= win then
        -- check the buftype in window v is empty string.
        -- if yes, then set current window to v.
        local buf = vim.api.nvim_win_get_buf(v)
        if vim.bo[buf].buftype == '' then
          vim.api.nvim_set_current_win(v)
          is_set = true
          break
        end
      end
    end
  end
end

M.init = function()
  -- vim.api.nvim_create_autocmd('BufLeave', {
  --   pattern = '*',
  --   callback = prevent_open_in_nofile_window,
  -- })
end

return M
