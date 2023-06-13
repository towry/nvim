local plug = require('libs.runtime.pack').plug
local keymap = require('libs.runtime.keymap')
local cmdstr = keymap.cmdstr
local cmd_modcall = keymap.cmd_modcall
local pickers_mod = 'libs.telescope.pickers'


plug({
  'kyazdani42/nvim-tree.lua',
  cmd = {
    'NvimTreeToggle',
    'NvimTreeFindFileToggle',
    'NvimTreeFindFile',
  },
  keys = {
    {
      '<leader>et',
      cmd_modcall('libs.plugin-nvim-tree', 'toggle_nvim_tree()'),
      desc = 'Toggle explore tree',
    },
    {
      '<leader>e.',
      cmd_modcall('libs.plugin-nvim-tree', 'nvim_tree_find_file({fallback=true})'),
      desc = 'Locate current file in tree',
    },
    {
      -- <cmd-b> to find file.
      '<Char-0xAC>',
      cmd_modcall('libs.plugin-nvim-tree', 'nvim_tree_find_file({fallback=true})'),
      desc = 'Locate current file in tree',
    }
  },
  config = function()
    local HEIGHT_RATIO = 0.8 -- You can change this
    local WIDTH_RATIO = 0.5  -- You can change this too
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
      on_attach = require('libs.plugin-nvim-tree.attach').on_attach,
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
  end
})

plug({
  enabled = false,
  "nvim-neo-tree/neo-tree.nvim",
  cmd = "Neotree",
  keys = {
    {
      "<leader>et",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = require("libs.runtime.utils").get_root() })
      end,
      desc = "Explorer NeoTree (root dir)",
    },
    {
      "<leader>eT",
      function()
        require("neo-tree.command").execute({ toggle = true, dir = vim.loop.cwd() })
      end,
      desc = "Explorer NeoTree (cwd)",
    },
  },
  deactivate = function()
    vim.cmd([[Neotree close]])
  end,
  init = function()
    vim.g.neo_tree_remove_legacy_commands = 1
    if vim.fn.argc() == 1 then
      local stat = vim.loop.fs_stat(vim.fn.argv(0))
      if stat and stat.type == "directory" then
        require("neo-tree")
      end
    end
  end,
  opts = {
    sources = { "filesystem", "buffers", "git_status", "document_symbols" },
    open_files_do_not_replace_types = { "terminal", "Trouble", "qf", "Outline" },
    filesystem = {
      bind_to_cwd = false,
      follow_current_file = true,
      use_libuv_file_watcher = true,
    },
    window = {
      mappings = {
        ["<space>"] = "none",
      },
    },
    default_component_configs = {
      indent = {
        with_expanders = true, -- if nil and file nesting is enabled, will enable expanders
        expander_collapsed = "",
        expander_expanded = "",
        expander_highlight = "NeoTreeExpander",
      },
    },
  },
  config = function(_, opts)
    require("neo-tree").setup(opts)
    vim.api.nvim_create_autocmd("TermClose", {
      pattern = "*lazygit",
      callback = function()
        if package.loaded["neo-tree.sources.git_status"] then
          require("neo-tree.sources.git_status").refresh()
        end
      end,
    })
  end,
})

plug({
  'stevearc/oil.nvim',
  lazy = not vim.cfg.runtime__starts_in_buffer,
  opts = {
    default_file_explorer = true,
    keymaps = {
      ["g?"] = "actions.show_help",
      ["<CR>"] = "actions.select",
      ["<C-v>"] = "actions.select_vsplit",
      ["<C-x>"] = "actions.select_split",
      ["<C-t>"] = "actions.select_tab",
      ["<C-p>"] = "actions.preview",
      ["<C-c>"] = "actions.close",
      ["<C-l>"] = "actions.refresh",
      ["-"] = "actions.parent",
      ["_"] = "actions.open_cwd",
      ["`"] = "actions.cd",
      ["~"] = "actions.tcd",
      ["g."] = "actions.toggle_hidden",
    },
    use_default_keymaps = false,
    float = {
      padding = 3,
      border = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
      win_options = {
        winblend = 0,
      }
    }
  },
  keys = {
    {
      '<leader>eO',
      function()
        local cwd = require('libs.runtime.utils').get_root()
        require('oil').open(cwd)
      end,
      desc = 'Open oil(CWD) file browser',
    },
    {
      '<leader>eo',
      function()
        require('oil').open()
      end,
      desc = 'Open oil(BUF) file browser',
    },
    {
      -- Hyper+e
      '<C-S-A-e>',
      function()
        require('oil').open()
      end,
      desc = 'Open oil(BUF) file browser'
    }
  }
})

plug({
  'simrat39/symbols-outline.nvim',
  keys = {
    { '<leader>/o',  '<cmd>SymbolsOutline<cr>', desc = 'Symbols outline' },
    -- <CMD-o> open the outline.
    { '<Char-0xAF>', '<cmd>SymbolsOutline<cr>', desc = 'Symbols outline' },
  },
  cmd = { 'SymbolsOutline', 'SymbolsOutlineOpen', 'SymbolsOutlineClose' },
  opts = {
    -- https://github.com/simrat39/symbols-outline.nvim
    show_guides = true,
    auto_preview = false,
    show_relative_numbers = true,
    autofold_depth = 2,
    width = 20,
    auto_close = true, -- auto close after selection
    keymaps = {
      close = { "<Esc>", "q", "Q", "<leader>x" },
      focus_location = '<S-CR>',
    },
    lsp_blacklist = {
      "null-ls",
      "tailwindcss",
    },
  }
}
)

plug({
  'nvim-pack/nvim-spectre',
  opts = {
    color_devicons = true,
    open_cmd = 'vnew',
    live_update = true,
    is_insert_mode = false,
    is_open_target_win = false,
  },
  cmd = { 'Spectre' },
  keys = {
    {
      '<leader>sp',
      function()
        require('spectre').open_visual()
      end,
      desc = 'Open Search and replace panel',
    },
    {
      '<leader>sP',
      function()
        local path = vim.fn.fnameescape(vim.fn.expand('%:p:.'))
        if vim.loop.os_uname().sysname == 'Windows_NT' then path = vim.fn.substitute(path, '\\', '/', 'g') end
        require('spectre').open({
          path = path,
          is_close = true,
          search_text = vim.fn.expand('<cword>'),
        })
      end,
      desc = 'Search and replace cword in current file'
    }
  }
})

plug({
  --- In the SSR float window you can see the placeholder
  --- search code, you can replace part of it with wildcards.
  --- A wildcard is an identifier starts with $, like $name.
  --- A $name wildcard in the search pattern will match any
  --- AST node and $name will reference it in the replacement.
  "cshuaimin/ssr.nvim",
  module = "ssr",
  keys = {
    {
      '<leader>sr',
      '<cmd>lua require("ssr").open()<cr>',
      mode = { 'n', 'x' },
      desc = 'Replace with Treesitter structure(SSR)',
    }
  },
  opts = {
    border = "rounded",
    min_width = 50,
    min_height = 5,
    max_width = 120,
    max_height = 25,
    keymaps = {
      close = "q",
      next_match = "n",
      prev_match = "N",
      replace_confirm = "<cr>",
      replace_all = "<S-CR>",
    },
  },
}
)

plug({
  'nvim-telescope/telescope.nvim',
  cmd = { 'Telescope' },
  keys = {
    { '<Tab>',      cmd_modcall(pickers_mod, 'buffers()'),                           desc = "List Buffers" },
    { '<leader>gB', cmdstr([[Telescope git_branches]]),                              desc = 'Git branchs' },
    { '<leader>ef', cmd_modcall(pickers_mod, 'project_files()'),                     desc = 'Open Project files' },
    { '<leader>eF', cmd_modcall(pickers_mod, 'project_files({use_all_files=true})'), desc = 'Open find all files' },
    {
      '<leader>ee',
      cmd_modcall('telescope.builtin', 'resume()'),
      desc =
      'Resume telescope pickers'
    },
    {
      '<leader>er',
      cmd_modcall(pickers_mod, 'project_files({ cwd_only = true, oldfiles = true })'),
      desc =
      'Open recent files'
    },
    { '<leader>el', cmd_modcall('libs.telescope.find-folders-picker', '()'),                desc = 'Find folders' },
    { '<leader>es', cmd_modcall('telescope', 'extensions.live_grep_args.live_grep_args()'), desc = 'Grep search' }
  },
  dependencies = {
    { 'nvim-lua/popup.nvim' },
    { 'nvim-lua/plenary.nvim' },
    { 'ThePrimeagen/git-worktree.nvim' },
    { 'nvim-telescope/telescope-live-grep-args.nvim' },
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
    {
      'tknightz/telescope-termfinder.nvim',
    },
  },
  config = function()
    local keymap = require('libs.runtime.keymap')
    local au = require('libs.runtime.au')
    local has_plugin = require('libs.runtime.utils').has_plugin
    local actions = require('telescope.actions')
    local action_state = require('telescope.actions.state')
    local lga_actions = require('telescope-live-grep-args.actions')

    local win_pick = require('window-picker')
    local action_set = require('telescope.actions.set')
    local icons = require('libs.icons')

    local git_icons = {
      added = icons.gitAdd,
      changed = icons.gitChange,
      copied = '>',
      deleted = icons.gitRemove,
      renamed = '➡',
      unmerged = '‡',
      untracked = '?',
    }

    require('telescope').setup({
      defaults = {
        winblend = 15,
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
          bottom_pane = {
            preview_width = 0.4,
            -- When columns are less than this value, the preview will be disabled
            preview_cutoff = 10,
          },
          prompt_position = 'bottom',
        },
        ---@see https://github.com/nvim-telescope/telescope.nvim/issues/522#issuecomment-1107441677
        file_ignore_patterns = { "node_modules", '.turbo', 'dist' },
        path_display = { 'truncate' },
        -- layout_strategy = 'flex',
        layout_strategy = "bottom_pane",
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
          -- theme = "dropdown",
          -- layout_strategy = "bottom_pane",
          layout_config = {
            prompt_position = "bottom",
            width = 0.9,
          },
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
    require('telescope').load_extension('termfinder')
    au.do_useraucmd(au.user_autocmds.TelescopeConfigDone_User)

    -- colorscheme
    au.register_event(au.events.AfterColorschemeChanged, {
      name = "telescope_ui",
      immediate = true,
      callback = function()
        vim.cmd('hi! link TelescopeBorder FloatBorder')
        vim.cmd('hi! link TelescopePromptNormal FloatBorder')
      end
    })
  end,
}
)
