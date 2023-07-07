--- https://raw.githubusercontent.com/softinio/nvim-metals/a743311d1239e2a211345ca37dc236e96069cce8/lua/telescope/_extensions/metals.lua

local M = {}

local cwd = nil
local legendary_registered = false
local item_group_name = 'folder_actions'

function M.enter(new_cwd)
  cwd = new_cwd
  return M
end

local get_current_cwd = function() return cwd end

function M.then_folder_action()
  local lg = require('legendary')
  local select_prompt = 'Folder action under: ' .. require('userlib.runtime.path').home_to_tilde(cwd)

  if not cwd then return end

  if legendary_registered then
    lg.find({
      select_prompt = select_prompt,
      itemgroup = item_group_name,
    })
    return
  end
  legendary_registered = true

  lg.funcs({
    itemgroup = 'folder_actions',
    description = 'Folder actions',
    funcs = {
      {
        description = 'Open with mini.files',
        function()
        end,
      },
      {
        description = 'Open with NVimTree',
        function()
        end,
      },
      {
        description = 'Find files with telescope',
        function()
          require('userlib.telescope.pickers').project_files({
            cwd = get_current_cwd(),
            use_all_files = true,
          })
        end,
      },
      {
        description = 'Recent files',
        function()
          require('userlib.telescope.pickers').project_files({
            oldfiles = true,
            cwd_only = true,
            cwd = get_current_cwd(),
          })
        end,
      },
      {
        description = 'Search content',
        function()
          require('userlib.telescope.live_grep_call')({
            cwd = get_current_cwd(),
          })
        end,
      },
    }
  })

  lg.find({
    select_prompt = select_prompt,
    itemgroup = item_group_name,
  })
end

return M
