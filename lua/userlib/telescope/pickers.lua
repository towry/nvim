--- https://github.dev/tjdevries/config_manager/blob/master/xdg_config/nvim/plugin/options.lua
local M = {}

local use_find_files_instead_of_git = true

M.project_files_toggle_between_git_and_fd = function()
  use_find_files_instead_of_git = not use_find_files_instead_of_git
end

M.project_files = function(opts)
  local action_state = require('telescope.actions.state')

  local map_i_actions = function(_, map)
    map('i', '<C-o>', function(prompt_bufnr)
      require('userlib.telescope.picker_keymaps').open_selected_in_window(prompt_bufnr)
    end, { noremap = true, silent = true })
    --- not working.
    --- https://github.com/nvim-telescope/telescope-file-browser.nvim/blob/master/lua/telescope/_extensions/file_browser/actions.lua#L598
    map('i', '<C-g>', function(prompt_bufnr)
      local current_picker = action_state.get_current_picker(prompt_bufnr)
      local finder = current_picker.finder
      finder.path = vim.cfg.runtime__starts_cwd
      finder.cwd = finder.path
      current_picker:refresh(finder, {
        reset_prompt = true,
        multi = current_picker._multi,
      })
    end, {
      desc = 'Go to home dir',
    })
    map('i', '<C-t>', function(prompt_bufnr)
      local current_picker = action_state.get_current_picker(prompt_bufnr)
      local finder = current_picker.finder
      vim.print(finder.opts)

      finder.hidden = not finder.hidden
      current_picker:refresh(finder, { reset_prompt = false, hidden = true, multi = current_picker._multi })
    end, {
      desc = 'Toggle hidden',
      remap = false,
      noremap = true,
    })
  end

  opts = opts or {}
  if not opts.cwd then
    opts.cwd = safe_cwd(vim.t.Cwd)
  end
  -- opts.hidden = true

  local nicely_cwd = ' ' .. vim.fn.fnamemodify(require('userlib.runtime.path').home_to_tilde(opts.cwd), ':t')
  opts.prompt_title = opts.prompt_title or nicely_cwd

  opts.attach_mappings = function(_, map)
    map_i_actions(_, map)
    return true
  end

  if opts and opts.oldfiles then
    opts.results_title = ' Recent files:'
    opts.include_current_session = true
    --- we want recent files inside monorepo root folder, not a sub project root.
    --- see https://github.com/nvim-telescope/telescope.nvim/blob/276362a8020c6e94c7a76d49aa00d4923b0c02f3/lua/telescope/builtin/__internal.lua#L533C61-L533C61
    if opts.cwd then
      opts.cwd_only = false
    end
    require('telescope.builtin').oldfiles(opts)
    return
  end

  -- use find_files or git_files.
  local use_all_files = opts.use_all_files or false
  if (opts and opts.no_gitfiles) or use_find_files_instead_of_git then
    use_all_files = true
  end

  local ok = (function()
    if use_all_files then
      return false
    end
    opts.results_title = '  Git Files: '
    local is_git_ok = pcall(require('telescope.builtin').git_files, opts)
    return is_git_ok
  end)()
  if not ok then
    opts.results_title = ' All Files:'
    require('telescope.builtin').find_files(opts)
  end
end

--- - <C-e>: open the command line with the text of the selected.
M.command_history = function()
  local builtin = require('telescope.builtin')

  builtin.command_history(require('userlib.telescope.themes').get_dropdown({
    color_devicons = true,
    winblend = 4,
    layout_config = {
      width = function(_, max_columns, _)
        return math.min(max_columns, 100)
      end,
      height = function(_, _, max_lines)
        return math.min(max_lines, 15)
      end,
    },
    filter_fn = function(cmd)
      return not vim.tbl_contains({
        'h',
        ':',
        'w',
        'wa',
        'q',
        'qa',
        'qa!',
      }, vim.trim(cmd))
    end,
  }))
end

function M.grep_string_visual()
  local visual_selection = function()
    local save_previous = vim.fn.getreg('a')
    vim.api.nvim_command('silent! normal! "ay')
    local selection = vim.fn.trim(vim.fn.getreg('a'))
    vim.fn.setreg('a', save_previous)
    return vim.fn.substitute(selection, [[\n]], [[\\n]], 'g')
  end
  require('telescope.builtin').live_grep({
    default_text = visual_selection(),
  })
end

function M.search_only_certain_files()
  local builtin = require('telescope.builtin')
  builtin.find_files({
    find_command = {
      'rg',
      '--files',
      '--type',
      vim.fn.input('Type: '),
    },
  })
end

function M.curbuf()
  local builtin = require('telescope.builtin')

  local opts = require('userlib.telescope.themes').get_dropdown({
    skip_empty_lines = true,
    winblend = 10,
    previewer = true,
    shorten_path = false,
    layout_config = {
      width = 0.8,
    },
  })
  builtin.current_buffer_fuzzy_find(opts)
end

M.edit_neovim = function()
  local builtin = require('telescope.builtin')

  builtin.git_files(require('userlib.telescope.themes').get_dropdown({
    color_devicons = true,
    cwd = '~/.config/nvim',
    previewer = false,
    prompt_title = 'NeoVim Dotfiles',
    sorting_strategy = 'ascending',
    winblend = 4,
    layout_config = {
      horizontal = {
        mirror = false,
      },
      vertical = {
        mirror = false,
      },
      prompt_position = 'top',
    },
  }))
end

function M.buffers_or_recent(cwd_only)
  local count = #vim.fn.getbufinfo({ buflisted = 1 })
  if count <= 1 then
    --- open recent.
    M.project_files(require('userlib.telescope.themes').get_dropdown({
      cwd_only = cwd_only or false,
      cwd = vim.cfg.runtime__starts_cwd,
      oldfiles = true,
      previewer = false,
    }))
    return
  end
  return M.buffers(cwd_only)
end

function M.buffers(cwd_only)
  local builtin = require('telescope.builtin')
  local actions = require('telescope.actions')
  local actionstate = require('telescope.actions.state')
  local Buffer = require('userlib.runtime.buffer')

  builtin.buffers(require('userlib.telescope.themes').get_dropdown({
    ignore_current_buffer = true,
    sort_mru = true,
    cwd_only = cwd_only,
    previewer = false,
    attach_mappings = function(prompt_bufnr, map)
      local close_buf = function()
        local selection = actionstate.get_selected_entry()
        actions.close(prompt_bufnr)
        if not vim.api.nvim_buf_is_valid(selection.bufnr) then
          return
        end
        vim.api.nvim_buf_delete(selection.bufnr, { force = false })
        local state = require('telescope.state')
        local cached_pickers = state.get_global_key('cached_pickers') or {}
        -- remove this picker cache
        table.remove(cached_pickers, 1)
      end

      local open_selected = function()
        local entry = actionstate.get_selected_entry()
        if not vim.api.nvim_buf_is_valid(prompt_bufnr) then
          return
        end
        actions.close(prompt_bufnr)
        if not entry or not entry.bufnr then
          vim.notify('no selected entry found')
          return
        end
        local bufnr = entry.bufnr
        if not vim.api.nvim_buf_is_valid(bufnr) then
          return
        end
        Buffer.set_current_buffer_focus(bufnr)
      end

      local open_findfiles = function()
        local current_query = actionstate.get_current_line()
        actions.close(prompt_bufnr)
        M.project_files({
          default_text = current_query,
        })
      end

      map('i', '<C-f>', open_findfiles)
      map('i', '<C-h>', close_buf)
      map('i', '<CR>', open_selected)
      -- pick window to open.
      map('i', '<C-o>', function(prompt_bufnr_)
        require('userlib.telescope.picker_keymaps').open_selected_in_window(prompt_bufnr_)
      end, { noremap = true, silent = true })

      return true
    end,
  }))
end

return M
