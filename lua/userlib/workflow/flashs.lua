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
    search = { mode = 'search', max_length = 0, multi_window = opts.multi_window or false, exclude = opts.exclude },
    label = { after = { 0, 0 } },
    pattern = '\\(^\\s*\\)\\@<=\\S',
    action = action,
  })
end

--- You can use <v:count> to specific which target win.
--- copy remote line in current cursor position and insert it at current cursor
--- position.
function M.copy_remote_line()
  local winindex = vim.v.count
  M.jump_to_line({
    multi_window = true,
    exclude = {
      function(win)
        local lastwinidx = vim.fn.winnr('$')
        if winindex >= 1 and winindex <= lastwinidx then
          return win ~= vim.fn.win_getid(winindex)
        end
        return false
      end,
    },
    action = function(match)
      local win = match.win
      local match_pos = match.pos
      -- run in target win
      vim.api.nvim_win_call(win, function()
        -- copy line in win at match_pos and insert it into current cursor
        -- position.
        vim.fn.setreg('+', vim.fn.getline(match_pos[1]))
        --- run in current win.
        vim.api.nvim_win_call(0, function()
          vim.schedule(function()
            vim.api.nvim_command('normal! "+p')
            vim.api.nvim_command('normal! V=')
          end)
        end)
      end)
    end,
  })
end

return M
