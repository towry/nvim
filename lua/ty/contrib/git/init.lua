local M = {}

local function setup_lazyload_for_git()
  require('ty.core.autocmd').with_group('git_lazy_load'):create('BufReadPost', {
    pattern = "*",
    callback = function()
      -- in nvim diff mode.
      if vim.wo.diff then
        vim.cmd('GitConflictRefresh')
      end
    end,
  })
end

M.init = function()
  -- setup lazy load for git stuff.
  setup_lazyload_for_git()
end

return M
