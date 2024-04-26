local M = {}

---@param keywords string[]
function M.grep_keywords(keywords)
  local query = table.concat(keywords, '|') .. [[\(.*\)]]
  if vim.cfg.plugin_fzf_or_telescope == 'fzf' then
    return require('fzf-lua').grep({ search = query, no_esc = true })
  end

  return require('telescope.builtin').live_grep({
    default_text = query,
  })
end

function M.quickfix_stack()
  if vim.cfg.plugin_fzf_or_telescope == 'fzf' then
    vim.cmd('FzfLua quickfix_stack')
  else
    vim.cmd('Telescope quickfixhistory')
  end
end

function M.command_history()
  if vim.cfg.plugin_fzf_or_telescope == 'fzf' then
    vim.cmd('FzfLua command_history')
  else
    vim.cmd('Telescope command_history')
  end
end

return M
