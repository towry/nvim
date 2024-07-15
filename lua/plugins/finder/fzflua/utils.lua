local M = {}

function M.get_last_query()
  local fzflua = require('fzf-lua')
  return vim.trim(fzflua.config.__resume_data.last_query or '')
end

return M
