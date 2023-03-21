--- picker for finding folders.
--- after folder is selected, we can choose to reveal it
--- on nvim-tree etc.

-- current cwd for the picker.
local find_folders_cwd = nil

--- TODO: add opt to customize the action when item is selected.
return function()
  if find_folders_cwd == nil then find_folders_cwd = vim.fn.getcwd() end

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
  local nvim_tree_api = require('nvim-tree.api')
  local nvim_tree_utils = require('nvim-tree.utils')
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

            local new_cwd = nvim_tree_utils.path_join({ find_folders_cwd, selected })
            nvim_tree_api.tree.open({
              update_root = false,
              find_file = false,
              current_window = false,
            })
            nvim_tree_api.tree.change_root(new_cwd)
          end)

          -- search inside folder.
          map('i', "<C-s>", function()
            actions.close(prompt_bufnr)
            local selection = action_state.get_selected_entry()
            if not selection then return false end

            local selected = selection[1]
            require('telescope').extensions.live_grep_args.live_grep_args({
              prompt_title = 'Grep search inside: ' .. selected,
              cwd = selected,
            })
          end)

          -- need return true to use default mappings.
          return true
        end,
      })
      :find()
end
