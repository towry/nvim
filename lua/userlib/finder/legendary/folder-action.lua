return function(cwd)
  local lg = require('legendary')
  local filters = require('legendary.filters')
  local Toolbox = require('legendary.toolbox')

  lg.funcs({
    itemgroup = 'Folder actions',
    description = 'Folder actions',
    funcs = {
      {
        description = 'Find files with telescope',
        function()
          require('userlib.telescope.pickers').project_files({
            cwd = cwd,
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
            cwd = cwd,
          })
        end,
      },
      {
        description = 'Search content',
        function()
          require('userlib.telescope.live_grep_call')({
            cwd = cwd,
          })
        end,
      },
    }
  })

  lg.find({
    select_prompt = 'Folder action under: ' .. require('userlib.runtime.path').home_to_tilde(cwd),
    filters = {
      filters.AND(Toolbox.is_itemgroup, function(item)
        return item.name == 'Folder actions'
      end)
    }
  })
end
