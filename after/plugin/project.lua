do
  if vim.g.project_plugin_loaded == 1 then
    return
  end
  vim.g.project_plugin_loaded = 1
end

local group = vim.api.nvim_create_augroup('project_plugin', { clear = true })

--- disable event in cdo, cfdo etc.
vim.api.nvim_create_autocmd({ 'BufReadPre' }, {
  group = group,
  callback = function()
    if vim.g.eventignore == 'Syntax' then
      return
    end
    local eventignore = vim.opt.eventignore:get()
    if vim.tbl_contains(eventignore, 'Syntax') then
      vim.g.eventignore = 'Syntax'
      vim.opt.eventignore:append('all')
    end

    vim.schedule(function()
      eventignore = vim.opt.eventignore:get()
      if not vim.tbl_contains(eventignore, 'Syntax') then
        vim.g.eventignore = nil
      end
    end)
  end,
})
