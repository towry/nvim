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

local use_find_files_instead_of_git = false

M.project_files_toggle_between_git_and_fd = function()
  use_find_files_instead_of_git = not use_find_files_instead_of_git
end

M.project_files = function(opts)
  local make_entry = require('telescope.make_entry')
  local strings = require('plenary.strings')
  local utils = require('telescope.utils')
  local entry_display = require('telescope.pickers.entry_display')
  local devicons = require('nvim-web-devicons')
  local def_icon = devicons.get_icon('fname', { default = true })
  local iconwidth = strings.strdisplaywidth(def_icon)

  opts = opts or {}
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
        { icon,            iconhl },
        tail,
        { path_to_display, 'TelescopeResultsComment' },
      })
    end
    return entry
  end

  if opts and opts.oldfiles then
    return require('telescope.builtin').oldfiles(opts)
  end

  if (opts and opts.no_gitfiles) or use_find_files_instead_of_git then
    return require('telescope.builtin').find_files(opts)
  end

  local ok = pcall(require('telescope.builtin').git_files, opts)
  if not ok then require('telescope.builtin').find_files(opts) end
end

M.command_history = function()
  local builtin = require('telescope.builtin')

  builtin.command_history(require('telescope.themes').get_dropdown({
    color_devicons = true,
    winblend = 4,
    layout_config = {
      width = function(_, max_columns, _) return math.min(max_columns, 150) end,
      height = function(_, _, max_lines) return math.min(max_lines, 15) end,
    },
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
    winblend = 10,
    previewer = false,
    shorten_path = false,
    borderchars = {
      prompt = { '─', '│', ' ', '│', '╭', '╮', '│', '│' },
      results = { '─', '│', '─', '│', '├', '┤', '╯', '╰' },
      preview = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    },
    border = {},
    layout_config = {
      width = 0.45,
      prompt_position = 'top',
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

-- Implement delta as previewer for diffs

M.my_git_commits = function(opts)
  local builtin = require('telescope.builtin')
  local previewers = require('telescope.previewers')
  local delta = previewers.new_termopen_previewer({
    get_command = function(entry)
      return { 'git', '-c', 'core.pager=delta', '-c', 'delta.side-by-side=false', 'diff', entry.value .. '^!' }
    end,
  })

  if not previewers then
    Ty.NOTIFY('telescope config error')
    return
  end
  opts = opts or {}
  opts.previewer = {
    delta,
    previewers.git_commit_message.new(opts),
    previewers.git_commit_diff_as_was.new(opts),
  }

  builtin.git_commits(opts)
end

M.my_git_bcommits = function(opts)
  local previewers = require('telescope.previewers')
  local builtin = require('telescope.builtin')

  local delta_bcommits = previewers.new_termopen_previewer({
    get_command = function(entry)
      return {
        'git',
        '-c',
        'core.pager=delta',
        '-c',
        'delta.side-by-side=false',
        'diff',
        entry.value .. '^!',
        '--',
        entry.current_file,
      }
    end,
  })

  opts = opts or {}
  opts.previewer = {
    delta_bcommits,
    previewers.git_commit_message.new(opts),
    previewers.git_commit_diff_as_was.new(opts),
  }

  builtin.git_bcommits(opts)
end

function M.buffers()
  local builtin = require('telescope.builtin')
  local actions = require('telescope.actions')
  local actionstate = require('telescope.actions.state')
  local Buffer = require('ty.core.buffer')

  builtin.buffers({
    ignore_current_buffer = true,
    sort_mru = true,
    -- layout_strategy = 'vertical',
    layout_strategy = "bottom_pane",
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
  })
end

function M.gen_from_buffer(opts)
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

  local cwd = vim.fn.expand(opts.cwd or vim.loop.cwd() or ".")

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
      { entry.bufnr,     'TelescopeResultsNumber' },
      { entry.indicator, 'TelescopeResultsComment' },
      { icon,            hl_group },
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
