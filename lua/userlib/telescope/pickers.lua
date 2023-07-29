--- https://github.dev/tjdevries/config_manager/blob/master/xdg_config/nvim/plugin/options.lua
local M = {}

M.get_path_and_tail = function(filename)
  local utils = require('telescope.utils')
  local bufname_tail = utils.path_tail(filename)
  local path_without_tail = require('plenary.strings').truncate(filename, #filename - #bufname_tail, '')
  local path_to_display = utils.transform_path({
    path_display = { 'truncate' },
  }, path_without_tail)

  return bufname_tail, path_to_display
end

local use_find_files_instead_of_git = true

M.project_files_toggle_between_git_and_fd = function()
  use_find_files_instead_of_git = not use_find_files_instead_of_git
end

M.project_files = function(opts)
  local action_state = require('telescope.actions.state')
  local make_entry = require('telescope.make_entry')
  local strings = require('plenary.strings')
  local utils = require('telescope.utils')
  local entry_display = require('telescope.pickers.entry_display')
  local devicons = require('nvim-web-devicons')
  local def_icon = devicons.get_icon('fname', { default = true })
  local iconwidth = strings.strdisplaywidth(def_icon)
  local level_up = vim.v.count

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
  end

  opts = opts or {}
  if not opts.cwd then
    -- opts.cwd = require('userlib.telescope.helpers').get_cwd_relative_to_buf(0, level_up)
    opts.cwd = vim.uv.cwd()
  end
  opts.hidden = true

  local nicely_cwd = require('userlib.runtime.path').home_to_tilde(opts.cwd)
  opts.prompt_title = opts.prompt_title or nicely_cwd

  opts.attach_mappings = function(_, map)
    map_i_actions(_, map)
    return true
  end

  --- //////// item stylish.
  local entry_make = make_entry.gen_from_file(opts)
  opts.entry_maker = function(line)
    local entry = entry_make(line)
    local displayer = entry_display.create({
      separator = ' ',
      items = {
        { width = iconwidth },
        { width = nil },
        { remaining = true },
      },
    })
    entry.display = function(et)
      -- https://github.com/nvim-telescope/telescope.nvim/blob/master/lua/telescope/make_entry.lua
      local tail_raw, path_to_display = M.get_path_and_tail(et.value)
      local tail = tail_raw .. ' '
      local icon, iconhl = utils.get_devicons(tail_raw)

      return displayer({
        { icon, iconhl },
        tail,
        { path_to_display, 'TelescopeResultsComment' },
      })
    end
    return entry
  end
  ---/// end item stylish

  if opts and opts.oldfiles then
    opts.results_title = '  Recent files: '
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
    if use_all_files then return false end
    opts.results_title = '  Git Files: '
    local is_git_ok = pcall(require('telescope.builtin').git_files, opts)
    return is_git_ok
  end)()
  if not ok then
    opts.results_title = '  All Files: '
    require('telescope.builtin').find_files(opts)
  end
end

--- - <C-e>: open the command line with the text of the selected.
M.command_history = function()
  local builtin = require('telescope.builtin')

  builtin.command_history(require('telescope.themes').get_dropdown({
    color_devicons = true,
    winblend = 4,
    layout_config = {
      width = function(_, max_columns, _) return math.min(max_columns, 100) end,
      height = function(_, _, max_lines) return math.min(max_lines, 15) end,
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
    end
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
  local themes = require('telescope.themes')

  local opts = themes.get_dropdown({
    skip_empty_lines = true,
    winblend = 10,
    previewer = true,
    shorten_path = false,
    borderchars = require('userlib.telescope.borderchars').dropdown_borderchars_default,
    border = true,
    layout_config = {
      width = 0.55,
    },
  })
  builtin.current_buffer_fuzzy_find(opts)
end

M.edit_neovim = function()
  local builtin = require('telescope.builtin')

  builtin.git_files(require('telescope.themes').get_dropdown({
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

function M.buffers_or_recent()
  local count = #vim.fn.getbufinfo({ buflisted = 1 })
  if count <= 1 then
    --- open recent.
    M.project_files(require('telescope.themes').get_dropdown({
      cwd_only = false,
      cwd = vim.cfg.runtime__starts_cwd,
      oldfiles = true,
      previewer = false,
      borderchars = require('userlib.telescope.borderchars').dropdown_borderchars_default,
    }))
    return
  end
  return M.buffers()
end

function M.buffers()
  local builtin = require('telescope.builtin')
  local actions = require('telescope.actions')
  local actionstate = require('telescope.actions.state')
  local Buffer = require('userlib.runtime.buffer')

  builtin.buffers(require('telescope.themes').get_dropdown({
    borderchars = require('userlib.telescope.borderchars').dropdown_borderchars_default,
    ignore_current_buffer = true,
    sort_mru = true,
    -- layout_strategy = 'vertical',
    -- layout_strategy = "bottom_pane",
    entry_maker = M.gen_from_buffer({
      bufnr_width = 2,
      sort_mru = true,
    }),
    attach_mappings = function(prompt_bufnr, map)
      local close_buf = function()
        -- local picker = actionstate.get_current_picker(prompt_bufnr)
        local selection = actionstate.get_selected_entry()
        actions.close(prompt_bufnr)
        vim.api.nvim_buf_delete(selection.bufnr, { force = false })
        local state = require('telescope.state')
        local cached_pickers = state.get_global_key('cached_pickers') or {}
        -- remove this picker cache
        table.remove(cached_pickers, 1)
      end

      local open_selected = function()
        local entry = actionstate.get_selected_entry()
        actions.close(prompt_bufnr)
        if not entry or (not entry.bufnr) then
          vim.notify("no selected entry found")
          return
        end
        local bufnr = entry.bufnr
        Buffer.set_current_buffer_focus(bufnr)
      end

      map('i', '<C-h>', close_buf)
      map('i', '<CR>', open_selected)

      return true
    end,
  }))
end

function M.gen_from_buffer(opts)
  local runtimeUtils = require('userlib.runtime.utils')
  local utils = require('telescope.utils')
  local strings = require('plenary.strings')
  local entry_display = require('telescope.pickers.entry_display')
  local Path = require('plenary.path')
  local make_entry = require('telescope.make_entry')

  opts = opts or {}

  local disable_devicons = opts.disable_devicons

  local icon_width = 0
  if not disable_devicons then
    local icon, _ = utils.get_devicons('fname', disable_devicons)
    icon_width = strings.strdisplaywidth(icon)
  end

  local cwd = vim.fn.expand(opts.cwd or runtimeUtils.get_root() or ".")

  local make_display = function(entry)
    -- bufnr_width + modes + icon + 3 spaces + : + lnum
    opts.__prefix = opts.bufnr_width + 4 + icon_width + 3 + 1 + #tostring(entry.lnum)
    local bufname_tail = utils.path_tail(entry.filename)
    local path_without_tail = require('plenary.strings').truncate(entry.filename, #entry.filename - #bufname_tail, '')
    local path_to_display = utils.transform_path({
      path_display = { 'truncate' },
    }, path_without_tail)
    local bufname_width = strings.strdisplaywidth(bufname_tail)
    local icon, hl_group = utils.get_devicons(entry.filename, disable_devicons)

    local displayer = entry_display.create({
      separator = ' ',
      items = {
        { width = opts.bufnr_width },
        { width = 4 },
        { width = icon_width },
        { width = bufname_width },
        { remaining = true },
      },
    })

    return displayer({
      { entry.bufnr, 'TelescopeResultsNumber' },
      { entry.indicator, 'TelescopeResultsComment' },
      { icon, hl_group },
      bufname_tail,
      { path_to_display .. ':' .. entry.lnum, 'TelescopeResultsComment' },
    })
  end

  return function(entry)
    local bufname = entry.info.name ~= '' and entry.info.name or '[No Name]'
    -- if bufname is inside the cwd, trim that part of the string
    bufname = Path:new(bufname):normalize(cwd)

    local hidden = entry.info.hidden == 1 and 'h' or 'a'
    -- local readonly = vim.api.nvim_buf_get_option(entry.bufnr, 'readonly') and '=' or ' '
    local readonly = vim.api.nvim_get_option_value('readonly', {
      buf = entry.bufnr,
    }) and '=' or ' '
    local changed = entry.info.changed == 1 and '+' or ' '
    local indicator = entry.flag .. hidden .. readonly .. changed
    local lnum = 1

    -- account for potentially stale lnum as getbufinfo might not be updated or from resuming buffers picker
    if entry.info.lnum ~= 0 then
      -- but make sure the buffer is loaded, otherwise line_count is 0
      if vim.api.nvim_buf_is_loaded(entry.bufnr) then
        local line_count = vim.api.nvim_buf_line_count(entry.bufnr)
        lnum = math.max(math.min(entry.info.lnum, line_count), 1)
      else
        lnum = entry.info.lnum
      end
    end

    return make_entry.set_default_entry_mt({
      value = bufname,
      ordinal = entry.bufnr .. ' : ' .. bufname,
      display = make_display,
      bufnr = entry.bufnr,
      filename = bufname,
      lnum = lnum,
      indicator = indicator,
    }, opts)
  end
end

return M
