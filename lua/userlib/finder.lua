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

--- Get extensions to be used in search glob.
function M.get_most_likely_searchable_exts()
  if vim.fn.executable('fd') ~= 1 then
    return
  end
  local res = vim
    .system({ 'fd', '-tf', '--max-results', 100, '--changed-within', '2weeks' }, { text = true, timeout = 100 })
    :wait()
  if res.code ~= 0 then
    return
  end
  local text = res.stdout
  if not text then
    return
  end
  local list = vim.split(text, '\n')
  local group = {}

  for _, path in pairs(list) do
    local ext = string.match(path, '%.([^%.]+)$')
    if ext ~= '' and ext then
      group[ext] = group[ext] or 0
      group[ext] = group[ext] + 1
    end
  end
  local results = {}

  for key, value in pairs(group) do
    -- for loop results, if value is great than the current, insert before.
    for _, v in ipairs(results) do
      if value > group[v] then
        table.insert(results, key)
        break
      end
    end
    -- insert to results
    table.insert(results, key)
  end

  -- return first 2 of results
  return vim.list_slice(results, 1, 3)
end

return M
