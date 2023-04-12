local M = {}

local HEIGHT_RATIO = 0.8 -- You can change this
local WIDTH_RATIO = 0.5  -- You can change this too
local TREE_INIT_WIDTH = 40

local function tree_actions_menu(node)
  local tree_actions = {
    {
      name = 'Create node',
      handler = require('nvim-tree.api').fs.create,
    },
    {
      name = 'Remove node',
      handler = require('nvim-tree.api').fs.remove,
    },
    {
      name = 'Trash node',
      handler = require('nvim-tree.api').fs.trash,
    },
    {
      name = 'Rename node',
      handler = require('nvim-tree.api').fs.rename,
    },
    {
      name = 'Fully rename node',
      handler = require('nvim-tree.api').fs.rename_sub,
    },
    {
      name = 'Copy',
      handler = require('nvim-tree.api').fs.copy.node,
    },
    -- ... other custom actions you may want to display in the menu
  }

  local entry_maker = function(menu_item)
    return {
      value = menu_item,
      ordinal = menu_item.name,
      display = menu_item.name,
    }
  end

  local finder = require('telescope.finders').new_table({
    results = tree_actions,
    entry_maker = entry_maker,
  })

  local sorter = require('telescope.sorters').get_generic_fuzzy_sorter()

  local default_options = {
    finder = finder,
    sorter = sorter,
    attach_mappings = function(prompt_buffer_number)
      local actions = require('telescope.actions')

      -- On item select
      actions.select_default:replace(function()
        local state = require('telescope.actions.state')
        local selection = state.get_selected_entry()
        -- Closing the picker
        actions.close(prompt_buffer_number)
        -- Executing the callback
        selection.value.handler(node)
      end)

      -- The following actions are disabled in this example
      -- You may want to map them too depending on your needs though
      actions.add_selection:replace(function()
      end)
      actions.remove_selection:replace(function()
      end)
      actions.toggle_selection:replace(function()
      end)
      actions.select_all:replace(function()
      end)
      actions.drop_all:replace(function()
      end)
      actions.toggle_all:replace(function()
      end)

      return true
    end,
  }

  -- Opening the menu
  require('telescope.pickers').new({ prompt_title = 'Tree menu' }, default_options):find()
end

function M.setup()
  local nvim_tree_api = require('nvim-tree.api')

  local git_icons = {
    unstaged = '',
    staged = '',
    unmerged = '',
    renamed = '➜',
    untracked = '',
    deleted = '',
    ignored = '◌',
  }

  local function enable_float_when_gui_narrow()
    local gwidth = vim.api.nvim_list_uis()[1].width
    local gheight = vim.api.nvim_list_uis()[1].height
    return gheight > gwidth
  end

  local function get_float_center_metrix()
    local screen_w = vim.opt.columns:get()
    local screen_h = vim.opt.lines:get() - vim.opt.cmdheight:get()
    local window_w = screen_w * WIDTH_RATIO
    local window_h = screen_h * HEIGHT_RATIO
    local window_w_int = math.floor(window_w)
    local window_h_int = math.floor(window_h)
    local center_x = (screen_w - window_w) / 2
    local center_y = ((vim.opt.lines:get() - window_h) / 2) - vim.opt.cmdheight:get()

    return {
      row = center_y,
      col = center_x,
      width = window_w_int,
      height = window_h_int,
    }
  end

  -- TODO: https://github.com/nvim-tree/nvim-tree.lua/wiki/Migrating-To-on_attach
  local keymappings = {
    { key = { '<CR>', 'o', '<2-LeftMouse>' }, action = 'edit' },
    -- <C-e> keymapping cannot be set because it's used for toggling nvim-tree
    -- { key = "<C-e>",                        action = "edit_in_place" },
    { key = { 'O' },                          action = 'edit_no_picker' },
    { key = { '<2-RightMouse>', '<C-]>' },    action = 'cd' },
    { key = '<C-v>',                          action = 'vsplit' },
    { key = '<C-x>',                          action = 'split' },
    -- { key = "<C-t>",                          action = "tabnew" },
    { key = '<',                              action = 'prev_sibling' },
    { key = '>',                              action = 'next_sibling' },
    { key = 'P',                              action = 'parent_node' },
    { key = '<BS>',                           action = 'close_node' },
    { key = '<Tab>',                          action = 'preview' },
    { key = 'K',                              action = 'first_sibling' },
    { key = 'J',                              action = 'last_sibling' },
    { key = 'I',                              action = 'toggle_ignored' },
    { key = 'H',                              action = 'toggle_dotfiles' },
    { key = 'R',                              action = 'refresh' },
    { key = 'a',                              action = 'create' },
    { key = 'd',                              action = 'remove' },
    { key = 'D',                              action = 'trash' },
    { key = 'r',                              action = 'rename' },
    { key = '<C-r>',                          action = 'full_rename' },
    { key = 'x',                              action = 'cut' },
    { key = 'c',                              action = 'copy' },
    { key = 'p',                              action = 'paste' },
    { key = 'y',                              action = 'copy_name' },
    { key = 'Y',                              action = 'copy_path' },
    { key = 'gy',                             action = 'copy_absolute_path' },
    { key = '[c',                             action = 'prev_git_item' },
    { key = ']c',                             action = 'next_git_item' },
    { key = '-',                              action = 'dir_up' },
    { key = 'X',                              action = 'system_open' },
    -- { key = 'q', action = 'close' },
    { key = '<Esc>',                          action = 'close' },
    { key = 'g?',                             action = 'toggle_help' },
    { key = 'W',                              action = 'collapse_all' },
    -- { key = "/",                              action = "search_node" },
    { key = 'f',                              action = 'live_filter' },
    { key = 'F',                              action = 'clear_live_filter' },
    { key = '<C-m>',                          action = 'tree actions',      action_cb = tree_actions_menu },
  }

  require('nvim-tree').setup({
    -- disables netrw completely
    disable_netrw = true,
    -- hijack netrw window on startup
    hijack_netrw = true,
    -- opens the tree when changing/opening a new tab if the tree wasn't previously opened
    open_on_tab = false,
    -- hijack the cursor in the tree to put it at the start of the filename
    hijack_cursor = true,
    -- updates the root directory of the tree on `DirChanged` (when your run `:cd` usually)
    update_cwd = true,
    -- opens in place of the unnamed buffer if it's empty
    hijack_unnamed_buffer_when_opening = false,
    --false by default, will change cwd of nvim-tree to that of new buffer's when opening nvim-tree
    respect_buf_cwd = false,
    -- show lsp diagnostics in the signcolumn
    diagnostics = {
      enable = false,
      icons = {
        hint = '',
        info = '',
        warning = '',
        error = '',
      },
    },
    renderer = {
      add_trailing = false,
      group_empty = true,
      highlight_git = true,
      highlight_opened_files = 'all',
      root_folder_modifier = ':~',
      indent_markers = {
        enable = true,
        icons = {
          corner = '└ ',
          edge = '│ ',
          none = '  ',
        },
      },
      icons = {
        glyphs = {
          git = git_icons,
        },
      },
    },
    -- update the focused file on `BufEnter`, un-collapses the folders recursively until it finds the file
    update_focused_file = {
      -- enables the feature
      enable = false,
      -- update the root directory of the tree to the one of the folder containing the file if the file is not under the current root directory
      -- only relevant when `update_focused_file.enable` is true
      update_cwd = true,
      -- list of buffer names / filetypes that will not update the cwd if the file isn't found under the current root directory
      -- only relevant when `update_focused_file.update_cwd` is true and `update_focused_file.enable` is true
      ignore_list = {},
    },
    -- configuration options for the system open command (`s` in the tree by default)
    system_open = {
      -- the command to run this, leaving nil should work in most cases
      cmd = '',
      -- the command arguments as a list
      args = {},
    },
    filters = {
      dotfiles = false,
      custom = {
        '^.git$',
      },
    },
    git = {
      enable = true,
      ignore = true,
      timeout = 300,
    },
    actions = {
      use_system_clipboard = true,
      change_dir = {
        enable = true,
        global = false,
        restrict_above_cwd = false,
      },
      open_file = {
        quit_on_open = false,
        -- if true the tree will resize itself after opening a file
        resize_window = true,
        window_picker = {
          enable = true,
          chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890',
          exclude = {
            filetype = { 'notify', 'packer', 'qf', 'diff', 'fugitive', 'fugitiveblame' },
            buftype = { 'nofile', 'terminal', 'help' },
          },
        },
      },
    },
    view = {
      -- width of the window, can be either a number (columns) or a string in `%`
      width = function()
        return enable_float_when_gui_narrow() and math.floor(vim.opt.columns:get() * WIDTH_RATIO) or TREE_INIT_WIDTH
      end,
      hide_root_folder = false,
      -- side of the tree, can be one of 'left' | 'right' | 'top' | 'bottom'
      side = 'left',
      mappings = {
        -- custom only false will merge the list with the default mappings
        -- if true, it will only use your list to set the mappings
        custom_only = true,
        -- list of mappings to set on the tree manually
        list = keymappings,
      },
      number = false,
      relativenumber = true,
      centralize_selection = true,
      adaptive_size = true,
      float = {
        enable = enable_float_when_gui_narrow(),
        open_win_config = function()
          local metrix = get_float_center_metrix()
          return {
            relative = 'editor',
            width = metrix.width,
            height = metrix.height,
            row = metrix.row,
            col = metrix.col,
            border = 'rounded',
            style = 'minimal',
          }
        end,
      },
    },
    trash = {
      cmd = 'trash',
      require_confirm = true,
    },
    live_filter = {
      prefix = '[FILTER]: ',
      always_show_folders = true,
    },
  })

  -- edit file on file creation from nvim tree.
  nvim_tree_api.events.subscribe(
    nvim_tree_api.events.Event.FileCreated,
    function(file)
      -- FIXME: check window count.
      vim.cmd('edit ' .. file.fname)
    end
  )
  -- nvim_tree_events.on_tree_open(function()
  --   bufferline_api.set_offset(TREE_WIDTH + 1, utils.add_whitespaces(13) .. 'File Explorer')
  -- end)
  --
  -- nvim_tree_events.on_tree_close(function()
  --   bufferline_api.set_offset(0)
  -- end)
end

local function run_nvim_tree_toggle_cmd(cmd)
  -- there will be error if we open tree on telescope prompt.
  -- https://neovim.io/doc/user/options.html#'buftype'
  local buftype = vim.api.nvim_buf_get_option(0, 'buftype')
  if buftype == 'prompt' then
    Ty.NOTIFY('please close the current prompt')
    return
  end
  vim.cmd(cmd)
end
function M.toggle_nvim_tree() run_nvim_tree_toggle_cmd('NvimTreeToggle') end

function M.toggle_nvim_tree_find_file() run_nvim_tree_toggle_cmd('NvimTreeFindFileToggle') end

function M.nvim_tree_find_file() run_nvim_tree_toggle_cmd('NvimTreeFindFile') end

return M
