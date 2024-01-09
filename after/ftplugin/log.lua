vim.defer_fn(function()
  vim.cmd.normal({ 'G', bang = true })
end, 1)
