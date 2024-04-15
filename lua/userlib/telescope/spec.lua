local M = {}

-- toggle `--hidden` & `--no-ignore` for the `find_files` picker
local function toggleHiddenAndIgnore(prompt_bufnr)
  local current_picker = require('telescope.actions.state').get_current_picker(prompt_bufnr)
  local cwd = tostring(current_picker.cwd or vim.loop.cwd()) -- cwd only set if passed as opt

  -- hidden status not stored, but title is, so we determine the previous state via title
  local prevTitle = current_picker.prompt_title
  local ignoreHidden = not prevTitle:find('hidden')

  local title = vim.fs.basename(cwd)
  if ignoreHidden then
    title = title .. ' (--hidden --no-ignore)'
  end
  local currentQuery = require('telescope.actions.state').get_current_line()
  local existingFileIgnores = require('telescope.config').values.file_ignore_patterns or {}

  require('telescope.actions').close(prompt_bufnr)
  require('telescope.builtin').find_files({
    default_text = currentQuery,
    prompt_title = title,
    hidden = ignoreHidden,
    no_ignore = ignoreHidden,
    cwd = cwd,
    -- prevent these becoming visible through `--no-ignore`
    file_ignore_patterns = {
      'node_modules',
      '.venv',
      'typings',
      '%.DS_Store$',
      '%.git/',
      '%.app/',
      unpack(existingFileIgnores), -- must be last for all items to be unpacked
    },
  })
end

M.config = function(_, opts)
  local au = require('userlib.runtime.au')
  require('telescope').setup(opts)
  require('telescope').load_extension('fzf')
  require('telescope').load_extension('live_grep_args')
  require('telescope').load_extension('termfinder')
  require('telescope').load_extension('zoxide')
  --- https://github.com/nvim-telescope/telescope-file-browser.nvim
  --- Telescope file_browser files=false
  require('telescope').load_extension('file_browser')
  au.do_useraucmd(au.user_autocmds.TelescopeConfigDone_User)
end

M.opts = function()
  local actions = require('telescope.actions')
  local action_state = require('telescope.actions.state')
  local lga_actions = require('telescope-live-grep-args.actions')
  local icons = require('userlib.icons')

  local git_icons = {
    added = icons.gitAdd,
    changed = icons.gitChange,
    copied = '>',
    deleted = icons.gitRemove,
    renamed = '➡',
    unmerged = '‡',
    untracked = '?',
  }

  return {
    defaults = {
      path_display = { 'tail' },
      border = true,
      borderchars = require('userlib.telescope.borderchars').dropdown_borderchars_default[1],
      wrap_results = false,
      --- give some opacity so we can see the window picker marks.
      winblend = 10,
      dynamic_preview_title = true,
      results_title = false,
      preview = { timeout = 400, filesize_limit = 1 }, -- ms & Mb
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
        width = 0.90,
        -- prompt_position = 'top',
        horizontal = {
          prompt_position = 'top',
          preview_cutoff = 70,
          width = { 0.75, min = 13 },
          preview_width = { 0.40, min = 30 },
        },
        vertical = {
          prompt_position = 'top',
          mirror = true,
          height = 0.9,
          preview_cutoff = 12,
          width = 0.7,
          preview_height = { 0.4, min = 10 },
          anchor = 'S',
        },
        flex = {
          preview_width = { 0.3, min = 20 },
        },
        bottom_pane = {
          preview_width = 0.4,
          -- When columns are less than this value, the preview will be disabled
          preview_cutoff = 10,
        },
      },
      -- generic_sorter = require('mini.fuzzy').get_telescope_sorter,
      ---@see https://github.com/nvim-telescope/telescope.nvim/issues/522#issuecomment-1107441677
      file_ignore_patterns = { 'node_modules/', '.turbo/', 'dist', '.git/' },
      layout_strategy = 'flex',
      -- file_sorter = require('telescope.sorters').get_fuzzy_file,
      color_devicons = true,
      initial_mode = 'insert',
      git_icons = git_icons,
      sorting_strategy = 'ascending',
      file_previewer = require('telescope.previewers').vim_buffer_cat.new,
      grep_previewer = require('telescope.previewers').vim_buffer_vimgrep.new,
      qflist_previewer = require('telescope.previewers').vim_buffer_qflist.new,
      mappings = {
        i = {
          --- used to move cursor forward.
          ['<C-f>'] = false,
          ['<S-BS>'] = function()
            --- delete previous W
            if vim.fn.mode() == 'n' then
              return
            end
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>gEldEa', true, true, true), 'n', false)
          end,
          ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
          ['<C-s>'] = actions.cycle_previewers_next,
          ['<C-a>'] = actions.cycle_previewers_prev,
          ['<C-h>'] = function()
            if vim.fn.mode() == 'n' then
              return
            end
            -- jump between WORD
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>gEa', true, true, true), 'n', false)
          end,
          ['<C-l>'] = function()
            if vim.fn.mode() == 'n' then
              return
            end
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>Ea', true, true, true), 'n', false)
          end,
          ['<ESC>'] = function(prompt_bufnr)
            local picker = action_state.get_current_picker(prompt_bufnr)
            local prompt = picker:_get_prompt()
            if not prompt or #prompt <= 0 then
              actions.close(prompt_bufnr)
              return
            end
            vim.cmd('stopinsert')
          end,
          ['<C-ESC>'] = actions.close,
          ['<C-c>'] = function(prompt_bufnr)
            local picker = action_state.get_current_picker(prompt_bufnr)
            picker:set_prompt('')
          end,
        },
        n = {
          ['<C-s>'] = actions.cycle_previewers_next,
          ['<C-a>'] = actions.cycle_previewers_prev,
          ['<C-h>'] = 'which_key',
        },
      },
    },
    pickers = {
      find_files = {
        mappings = {
          i = {
            ['<C-h>'] = { toggleHiddenAndIgnore, type = 'action' },
          },
        },
      },
      oldfiles = {
        previewer = false,
      },
    },
    extensions = {
      file_browser = {
        use_fd = true,
        mappings = {
          i = {
            ['<CR>'] = function(prompt_buf)
              local entry_path = action_state.get_selected_entry().Path
              local new_cwd = entry_path:is_dir() and entry_path:absolute() or entry_path:parent():absolute()

              actions.close(prompt_buf)
              require('userlib.mini.clue.folder-action').open(new_cwd)
            end,
          },
        },
      },
      live_grep_args = {
        disable_coordinates = true,
        auto_quoting = true, -- enable/disable auto-quoting
        mappings = {
          -- extend mappings
          i = {
            ['<C-k>'] = lga_actions.quote_prompt(),
            ['<C-o>'] = function(prompt_bufnr)
              return require('userlib.telescope.picker_keymaps').open_selected_in_window(prompt_bufnr)
            end,
          },
          ['n'] = {
            -- your custom normal mode mappings
            ['/'] = function()
              vim.cmd('startinsert')
            end,
          },
        },
      },
      zoxide = {
        --- https://github.com/jvgrootveld/telescope-zoxide
        prompt_title = 'Zz...',
        mappings = {
          default = {
            after_action = function(selection)
              print('Update to (' .. selection.z_score .. ') ' .. selection.path)
            end,
          },
          -- ["<C-s>"] = {
          --   before_action = function(selection) print("before C-s") end,
          --   action = function(selection)
          --     vim.cmd.edit(selection.path)
          --   end
          -- },
          -- -- Opens the selected entry in a new split
          -- ["<C-v>"] = { action = z_utils.create_basic_command("split") },
        },
      },
    },
  }
end

return M
