-- https://github.com/abzcoding/lvim/blob/87dd3f44d34313531acac144879d1a2dc493ce69/lua/user/telescope.lua#L1
local M = {}

local actions = nil
local icons = require('ty.contrib.ui.icons')
local has_plugin = require('ty.core.utils').has_plugin
local action_state = nil
local lga_actions = nil

local git_icons = {
  added = icons.gitAdd,
  changed = icons.gitChange,
  copied = '>',
  deleted = icons.gitRemove,
  renamed = '➡',
  unmerged = '‡',
  untracked = '?',
}

function M.setup()
  actions = require('telescope.actions')
  action_state = require('telescope.actions.state')
  lga_actions = require('telescope-live-grep-args.actions')

  local win_pick = require('window-picker')
  local action_set = require('telescope.actions.set')

  require('telescope').setup({
    defaults = {
      cache_picker = {
        num_pickers = 5,
      },
      vimgrep_arguments = {
        'rg',
        '--color=never',
        '--no-heading',
        '--with-filename',
        '--line-number',
        '--column',
        '--smart-case',
      },
      layout_config = {
        horizontal = {
          preview_cutoff = 120,
        },
        prompt_position = 'top',
      },
      ---@see https://github.com/nvim-telescope/telescope.nvim/issues/522#issuecomment-1107441677
      file_ignore_patterns = { "node_modules" },
      path_display = { 'truncate' },
      layout_strategy = 'flex',
      file_sorter = require('telescope.sorters').get_fzy_sorter,
      prompt_prefix = '',
      color_devicons = true,
      initial_mode = 'insert',
      git_icons = git_icons,
      sorting_strategy = 'ascending',
      file_previewer = require('telescope.previewers').vim_buffer_cat.new,
      grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
      qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
      mappings = {
        i = {
          ['<C-e>'] = function() vim.cmd('stopinsert') end,
          -- ["<C-x>"] = false,
          ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
          ['<C-s>'] = actions.cycle_previewers_next,
          ['<C-a>'] = actions.cycle_previewers_prev,
          ['<C-h>'] = 'which_key',
          ['<ESC>'] = actions.close,
          ['<C-c>'] = function(prompt_bufnr)
            local picker = action_state.get_current_picker(prompt_bufnr)
            picker:set_prompt('')
          end,
          -- open with pick window action.
          ['<C-o>'] = function(prompt_bufnr)
            local picker = action_state.get_current_picker(prompt_bufnr)
            local win_picked = win_pick.pick_window({
              autoselect_one = true,
              include_current_win = false,
            })
            -- allow cancelling.
            if not win_picked then return end
            action_state
                .get_current_history()
                :append(action_state.get_current_line(), action_state.get_current_picker(prompt_bufnr))
            picker.get_selection_window = function() return win_picked or 0 end
            return action_set.select(prompt_bufnr, 'default')
          end,
        },
        n = {
          ['<C-s>'] = actions.cycle_previewers_next,
          ['<C-a>'] = actions.cycle_previewers_prev,
        },
      },
    },
    extensions = {
      fzf = {
        override_generic_sorter = true,
        override_file_sorter = true,
        case_mode = 'ignore_case',
      },
      live_grep_args = {
        disable_coordinates = true,
        auto_quoting = true, -- enable/disable auto-quoting
        mappings = {
          -- extend mappings
          i = {
            ['<C-k>'] = lga_actions.quote_prompt(),
            ['<C-r>'] = function(prompt_bufnr)
              local picker = action_state.get_current_picker(prompt_bufnr)
              local prompt = picker:_get_prompt()
              picker:set_prompt('--no-fixed-strings ' .. prompt)
            end,
          },
          ['n'] = {
            -- your custom normal mode mappings
            ['/'] = function() vim.cmd('startinsert') end,
          },
        },
      },
    },
  })

  require('telescope').load_extension('fzf')
  require('telescope').load_extension('live_grep_args')
  require('telescope').load_extension('git_worktree')
  require('telescope').load_extension('cheatsheet')
  require('telescope').load_extension('termfinder')
  if has_plugin('project.nvim') then require('telescope').load_extension('projects') end

  -- colorscheme
  vim.cmd('hi! link TelescopeBorder FloatBorder')
  vim.cmd('hi! link TelescopePromptNormal FloatBorder')
end

return M
