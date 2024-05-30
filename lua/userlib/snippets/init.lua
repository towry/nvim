local M = {}

local function get_snippet_info_desc(description)
  if type(description) == 'string' then
    return description
  elseif type(description) == 'table' then
    return description[1]
  end
  return ''
end

function M.get_available_snippets()
  local lua_snippets = require('snippets')
  local snippets_flatten = {}

  --- { [snippet_name] = { body = 'string', description = 'string', prefix =
  --- 'string' }
  local availables = lua_snippets.loaded_snippets or {}

  for snippet_name, snippet_definition in pairs(availables) do
    table.insert(snippets_flatten, {
      name = snippet_name,
      description = get_snippet_info_desc(snippet_definition.description),
      body = snippet_definition.body,
      trigger = snippet_definition.prefix,
    })
  end

  return snippets_flatten
end

function M.fzf_complete_snippet(opts)
  local fzflua = require('fzf-lua')

  opts = opts or {}
  opts.winopts = {
    fullscreen = false,
  }

  local snippets = M.get_available_snippets()
  if #snippets <= 0 then
    vim.notify('No snippets found', vim.log.levels.WARN)
    return
  end

  if not opts.query then
    local match = '[^%s"\']*'
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2] + 1
    local before = col > 1 and line:sub(1, col - 1):reverse():match(match):reverse() or ''
    opts.query = before or ''
  end

  opts.actions = opts.actions
    or {
      ['default'] = function(selected, _opts)
        local select = selected[1]
        --- extract index from select by pattern index: ...
        local index = select:match('^%d+')
        local sp = snippets[tonumber(index)]
        if not sp then
          vim.notify('No snippets selected', vim.log.levels.WARN)
          return
        end

        if not sp.body then
          return
        end

        local body = type(sp.body) == 'string' and sp.body or table.concat(sp.body, '\n')

        vim.defer_fn(function()
          vim.cmd.startinsert()
          vim.snippet.expand(body)
        end, 1)
      end,
    }

  -- use snippets[index].description or .trigger
  local contents = vim
    .iter(ipairs(snippets))
    :map(function(i, snip)
      return string.format('%s: %s', i, snip.description or snip.name)
    end)
    :totable()

  return fzflua.fzf_exec(contents, opts)
end

return M
