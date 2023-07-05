--- picker for finding folders.
--- after folder is selected, we can choose to reveal it
--- on nvim-tree etc.

--- TODO: add opt to customize the action when item is selected.
return function(opts)
  opts = opts or {}
  local runtimeUtils = require('libs.runtime.utils')
  local find_folders_cwd = opts.cwd or runtimeUtils.get_root()

  local picker_opts = {
    cwd = find_folders_cwd,
    find_command = {
      'fd',
      '--type',
      'directory',
      '--exclude',
      '.git',
      '--exclude',
      '.idea',
      '--exclude',
      'node_modules',
      '--exclude',
      'dist',
      '--exclude',
      '.cache',
      '--color',
      'never',
    },
    layout_strategy = 'flex',
    previewer = false,
    prompt_title = 'Find folders',
  }
  local pickers = require('telescope.pickers')
  local conf = require('telescope.config').values
  local finders = require('telescope.finders')
  local libpath = require('libs.runtime.path')
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')

  pickers
      .new(picker_opts, {
        finder = finders.new_oneshot_job(picker_opts.find_command, picker_opts),
        sorter = conf.file_sorter(picker_opts),
        attach_mappings = function(prompt_bufnr, map)
          -- map("i", "asdf", "command")
          actions.select_default:replace(function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if not selection then return false end

            local selected = selection[1]

            local new_cwd = libpath.join(find_folders_cwd, selected)
            require('libs.finder.hook').trigger_select_folder_action(new_cwd)
          end)

          -- search inside folder.
          map('i', "<C-s>", function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if not selection then return false end

            local selected = selection[1]
            vim.schedule(function()
              require('telescope').extensions.live_grep_args.live_grep_args({
                prompt_title = 'Grep search inside: ' .. selected,
                cwd = selected,
              })
            end)
          end)

          -- need return true to use default mappings.
          return true
        end,
      })
      :find()
end
