_G.ScratchBuffer = {
  bufnr = nil,
}

local M = _G.ScratchBuffer

local function create(filetype)
  if filetype == nil or filetype == '' then
    filetype = 'markdown'
  end

  M.bufnr = vim.api.nvim_create_buf(true, true)

  vim.api.nvim_buf_set_name(M.bufnr, 'scratch.' .. filetype)
  vim.api.nvim_set_option_value('filetype', filetype, {
    buf = M.bufnr,
  })
  vim.bo[M.bufnr].buftype = 'nofile'
  vim.api.nvim_win_set_buf(0, M.bufnr)
end

local complete_fn = function()
  return {
    'lua',
    'javascript',
    'typescript',
    'javascriptreact',
    'typescriptreact',
    'python',
    'c',
    'cpp',
    'rust',
    'go',
    'markdown',
    'json',
    'jsonc',
    'toml',
    'yaml',
    'nix',
    'sh',
    'fish',
    'txt',
    'css',
    'scss',
  }
end

vim.api.nvim_create_user_command('ScratchBuffer', function(opts)
  create(opts.args)
end, {
  nargs = '?',
  complete = complete_fn,
  desc = 'Manage scratch buffer',
})
