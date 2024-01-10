local M = {}

function M.jump_to_line(opts)
  opts = opts or {}

  local action = opts.action
      and function(match, state)
        state:restore()
        vim.schedule(function()
          opts.action(match, state)
        end)
      end
    or nil

  require('flash').jump({
    search = { mode = 'search', max_length = 0 },
    label = { after = { 0, 0 } },
    pattern = '\\(^\\s*\\)\\@<=\\S',
    action = action,
  })
end

return M
