local M = {}

local function get_snippet_info_desc(description)
  if type(description) == 'string' then
    return description
  elseif type(description) == 'table' then
    return description[1]
  end
  return ''
end

--- get available snippets from luasnip by using luasnip.available() api
function M.get_available_snippets()
  local luasnip = require('luasnip')
  local snippets_flatten = {}
  local availables = luasnip.available() or {}

  for ft, snippets in pairs(availables) do
    for _, snippet in ipairs(snippets) do
      table.insert(snippets_flatten, {
        name = snippet.name,
        description = get_snippet_info_desc(snippet.description),
        ft = ft,
        trigger = snippet.trigger,
      })
    end
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
        local trigger = sp.trigger

        vim.schedule(function()
          --- if current cursor have word before, remove the word and insert
          --- trigger
          --- else insert trigger
          --- use vim.api.nvim_set_current_line api
          local line = vim.api.nvim_get_current_line()
          local col = vim.api.nvim_win_get_cursor(0)[2] + 1
          local has_before_word = col > 1 and line:sub(1, col - 1):match('%w+$')
          local after = line:sub(col)
          local before = has_before_word and line:sub(1, col - #has_before_word - 1) or line:sub(1, col - 1)
          vim.api.nvim_set_current_line(before .. trigger .. after)
          --- make sure cursor is in insert mode and after the inserted trigger
          --- so we can use tab to expand this snippet
          vim.cmd('normal! ' .. #trigger .. 'l')
          vim.cmd([[noautocmd lua vim.api.nvim_feedkeys('a', 'n', true)]])
        end)
      end,
    }

  -- use snippets[index].description or .trigger
  local contents = vim
    .iter(ipairs(snippets))
    :map(function(i, snip)
      return string.format('%s: %s', i, snip.description or snip.trigger)
    end)
    :totable()

  return fzflua.fzf_exec(contents, opts)
end

return M
