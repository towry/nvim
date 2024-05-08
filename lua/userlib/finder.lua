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

--- collect extensions from open buffers
--- return as glob pattern
function M.get_glob_from_open_buffers()
  local results = {}
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if vim.api.nvim_buf_is_loaded(buf) then
      if vim.api.nvim_get_option_value('buftype', { buf = buf }) == '' then
        local path = vim.api.nvim_buf_get_name(buf)
        local ext = string.match(path, '%.([^%.]+)$')
        if ext ~= '' and ext then
          results[ext] = true
        end
      end
    end
  end
  local lists = {}

  for key, _ in pairs(results) do
    table.insert(lists, key)
  end

  if #lists == 0 then
    return ''
  end
  return '--glob=*.{' .. table.concat(lists, ',') .. '}'
end

function M.get_grep_flags_with_glob()
  local cmd = '--smart-case --no-fixed-strings --fixed-strings -M 500'
  local glob = M.get_glob_from_open_buffers()
  return cmd .. ' ' .. glob
end

return M
