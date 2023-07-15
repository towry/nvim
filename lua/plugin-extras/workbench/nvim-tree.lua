local plug = require('userlib.runtime.pack').plug
local keymap = require('userlib.runtime.keymap')
local cmd_modcall = keymap.cmd_modcall
local au = require('userlib.runtime.au')

plug({
  'kyazdani42/nvim-tree.lua',
  cmd = {
    'NvimTreeToggle',
    'NvimTreeFindFileToggle',
    'NvimTreeFindFile',
  },
  enabled = false,
  keys = {
    {
      '<leader>ft',
      cmd_modcall('userlib.plugin-nvim-tree', 'toggle_nvim_tree()'),
      desc = 'Toggle explore tree',
    },
    {
      '<leader>f.',
      cmd_modcall('userlib.plugin-nvim-tree', 'nvim_tree_find_file_direct()'),
      desc = 'Locate current file in tree',
    },
    {
      '<localleader>b',
      cmd_modcall('userlib.plugin-nvim-tree', 'nvim_tree_find_file({fallback=true})'),
      -- cmd_modcall('userlib.plugin-nvim-tree', 'toggle_nvim_tree()'),
      desc = 'Locate current file in tree',
    },
  },
  config = function()
    local HEIGHT_RATIO = 0.8 -- You can change this
    local WIDTH_RATIO = 0.5 -- You can change this too
    local TREE_INIT_WIDTH = 40


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

    require('nvim-tree').setup({
      on_attach = require('userlib.plugin-nvim-tree.attach').on_attach,
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
      sync_root_with_cwd = true,
      -- opens in place of the unnamed buffer if it's empty
      hijack_unnamed_buffer_when_opening = false,
      --false by default, will change cwd of nvim-tree to that of new buffer's when opening nvim-tree
      respect_buf_cwd = true,
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
        indent_width = 1,
        indent_markers = {
          enable = false,
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
      filesystem_watchers = {
        enable = true,
        debounce_delay = 500,
        ignore_dirs = vim.cfg.runtime__folder_holes_inregex,
      },
      select_prompts = true,
      git = {
        enable = false,
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
              filetype = vim.cfg.misc__ft_exclude,
              buftype = vim.cfg.misc__buf_exclude,
            },
          },
        },
      },
      view = {
        preserve_window_proportions = true,
        signcolumn = 'no',
        -- width of the window, can be either a number (columns) or a string in `%`
        -- width = function()
        --   return enable_float_when_gui_narrow() and math.floor(vim.opt.columns:get() * WIDTH_RATIO) or {
        --     max = TREE_INIT_WIDTH * 1.5,
        --     min = TREE_INIT_WIDTH * 0.8,
        --   }
        -- end,
        width = {
          max = TREE_INIT_WIDTH * 1.5,
          min = TREE_INIT_WIDTH * 0.8,
        },
        hide_root_folder = false,
        -- side of the tree, can be one of 'left' | 'right' | 'top' | 'bottom'
        side = 'left',
        number = false,
        relativenumber = true,
        debounce_delay = 500,
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
  end,
  init = function()
    au.define_autocmd('UILeave', {
      group = '_nvim_tree_hide_on_ui_hide',
      callback = function()
        local nvim_tree_api = require('nvim-tree.api')
        local treeview = require('nvim-tree.view')
        local is_open = treeview.is_visible()
        if is_open then
          nvim_tree_api.close()
        end
      end
    })
  end,
})
