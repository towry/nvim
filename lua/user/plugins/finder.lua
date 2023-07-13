local plug = require('userlib.runtime.pack').plug
local keymap = require('userlib.runtime.keymap')
-- local cmdstr = keymap.cmdstr
local cmd_modcall = keymap.cmd_modcall
local pickers_mod = 'userlib.telescope.pickers'
local au = require('userlib.runtime.au')


plug({
  'kyazdani42/nvim-tree.lua',
  cmd = {
    'NvimTreeToggle',
    'NvimTreeFindFileToggle',
    'NvimTreeFindFile',
  },
  enabled = true,
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

plug({
  'kyoh86/vim-ripgrep',
  event = 'User LazyUIEnterOncePost',
  init = function()
    --- https://github.dev/qalshidi/vim-bettergrep
    -- abbr rg to Rg
    vim.cmd([[cnoreabbrev <expr> rg (getcmdtype() ==# ':' && getcmdline() ==# 'rg')  ? 'Rg' : 'rg']])
    vim.cmd([[command! -nargs=+ -complete=file Rg :call ripgrep#search(<q-args>)]])
  end,
})

plug({
  enabled = true,
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
      ["<C-r>"] = "actions.refresh",
      ["<C-o>"] = function()
        local oil = require('oil')
        -- type: file|directory
        local current = require('oil').get_cursor_entry()
        local lcwd = oil.get_current_dir()
        local file, folder = nil, nil
        if not current or current.type == 'directory' then
          file = nil
          folder = lcwd .. current.name
        elseif current.type == 'file' then
          folder = nil
          file = lcwd .. current.name
        end

        if folder then
          require('userlib.hydra.folder-action').open(folder, 0);
        else
          require('userlib.hydra.file-action').open(file, 0);
        end
      end,
      ["y"] = "actions.copy_entry_path",
      ["-"] = "actions.parent",
      ["_"] = function()
        if vim.w.oil_lcwd ~= nil then
          require('oil').open(vim.w.oil_lcwd)
          vim.w.oil_lcwd = nil
        else
          vim.w.oil_lcwd = require('oil').get_current_dir()
          --- toggle with current and project root.
          require('oil').open(require('userlib.runtime.utils').get_root())
        end
      end,
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
      '<leader>fo',
      function()
        require('oil').open(vim.cfg.runtime__starts_cwd)
      end,
      desc = 'Open oil(Root) file browser',
    },
    {
      '<leader>fO',
      function()
        require('oil').open(require('userlib.runtime.utils').get_root())
      end,
      desc = 'Open oil(BUF) file browser',
    },
    {
      '-',
      function()
        require('oil').open()
      end,
      desc = 'Open oil file browser(buf)',
    },
    {
      '_',
      function()
        require('oil').open_float()
      end,
      desc = 'Open oil file browser(buf|float)',
    },
  },
  init = function()
    au.define_autocmd('BufEnter', {
      group = '_oil_change_cwd',
      pattern = 'oil:///*',
      callback = function(ctx)
        vim.g.cwd = require('oil').get_current_dir()
        vim.g.cwd_short = require('userlib.runtime.path').home_to_tilde(vim.g.cwd)
        vim.cmd.lcd(vim.g.cwd)
      end,
    })
  end,
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
        if vim.uv.os_uname().sysname == 'Windows_NT' then path = vim.fn.substitute(path, '\\', '/', 'g') end
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
    {
      '<leader>fb',
      cmd_modcall(pickers_mod, 'curbuf()'),
      desc = 'Fuzzy search in current buffer',
    },
    {
      '<Tab>',
      cmd_modcall(pickers_mod, 'buffers_or_recent()'),
      desc =
      "List Buffers"
    },
    {
      '<leader>gb',
      function()
        require('userlib.ui.dropdown').select({
          items = {
            {
              label = 'Git branches',
              hint = 'local',
              'Telescope git_branches show_remote_tracking_branches=false',
            },
            {
              label = 'Git branches',
              hint = 'remotes',
              'Telescope git_branches',
            },
          }
        }, {
          prompt_title = 'Select action',
        })
      end,
      desc = 'Git branches'
    },
    {
      '<localleader>f',
      cmd_modcall(pickers_mod, 'project_files()'),
      desc =
      'Open Project files'
    },
    {
      '<leader>ff',
      cmd_modcall(pickers_mod, 'project_files({use_all_files=false, cwd=vim.cfg.runtime__starts_cwd})'),
      desc =
      'Open find all files'
    },
    {
      '<leader>fe',
      cmd_modcall('telescope.builtin', 'resume()'),
      desc =
      'Resume telescope pickers'
    },
    {
      '<localleader><Tab>',
      cmd_modcall(pickers_mod,
        [[project_files(require('telescope.themes').get_dropdown({ previewer = false, cwd_only = false, oldfiles = true, cwd = vim.cfg.runtime__starts_cwd }))]]),
      desc =
      'Open recent files'
    },
    {
      '<leader>fl',
      function()
        --- https://github.com/nvim-telescope/telescope-file-browser.nvim/blob/e03ff55962417b69c85ef41424079bb0580546ba/lua/telescope/_extensions/file_browser/actions.lua#L598
        require('telescope').extensions.file_browser.file_browser(require('telescope.themes').get_dropdown({
          files = false,
          use_fd = true,
          display_stat = false,
          hide_parent_dir = true,
          previewer = false,
          depth = 3,
          cwd = vim.cfg.runtime__starts_cwd,
        }))
      end,
      desc =
      'Find folders'
    },
    {
      '<localleader>l',
      function()
        --- https://github.com/nvim-telescope/telescope-file-browser.nvim/blob/e03ff55962417b69c85ef41424079bb0580546ba/lua/telescope/_extensions/file_browser/actions.lua#L598
        require('telescope').extensions.file_browser.file_browser(require('telescope.themes').get_dropdown({
          results_title = vim.g.cwd_short,
          files = false,
          use_fd = true,
          previewer = false,
          depth = 5,
          hide_parent_dir = true,
          display_stat = false,
          cwd = require('userlib.runtime.utils').get_root(),
        }))
      end,
      desc =
      'Find folders'
    },
    {
      '<leader>fs',
      function()
        require('userlib.telescope.live_grep_call')({
          cwd = vim.cfg.runtime__starts_cwd,
        })
      end,
      desc = 'Grep search'
    },
    {
      '<localleader>s',
      cmd_modcall('userlib.telescope.live_grep_call', '()'),
      desc =
      'Grep search'
    },
    {
      '<localleader>s',
      cmd_modcall('telescope-live-grep-args.shortcuts', 'grep_visual_selection()'),
      desc = 'Grep search on selection',
      mode = { 'v', 'x' }
    },
    {
      '<localleader>S',
      cmd_modcall('telescope-live-grep-args.shortcuts', 'grep_word_under_cursor()'),
      desc = 'Grep search on selection',
    },
  },
  dependencies = {
    { 'nvim-lua/popup.nvim' },
    { 'nvim-lua/plenary.nvim' },
    { 'ThePrimeagen/git-worktree.nvim' },
    -- { 'echasnovski/mini.fuzzy' },
    { 'nvim-telescope/telescope-live-grep-args.nvim' },
    {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make',
    },
    {
      'tknightz/telescope-termfinder.nvim',
    },
    {
      'pze/telescope-file-browser.nvim',
      dev = false,
    },
  },
  config = function(_, opts)
    require('telescope').setup(opts)
    require('telescope').load_extension('fzf')
    require('telescope').load_extension('live_grep_args')
    require('telescope').load_extension('git_worktree')
    require('telescope').load_extension('termfinder')
    --- https://github.com/nvim-telescope/telescope-file-browser.nvim
    --- Telescope file_browser files=false
    require("telescope").load_extension("file_browser")
    au.do_useraucmd(au.user_autocmds.TelescopeConfigDone_User)

    -- colorscheme
    au.register_event(au.events.AfterColorschemeChanged, {
      name = "telescope_ui",
      immediate = true,
      callback = function()
        vim.cmd('hi! link TelescopeNormal NormalFloat')
        vim.cmd('hi! link TelescopeBorder NormalFloat')
      end
    })
  end,
  opts = function()
    -- local au = require('userlib.runtime.au')
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
        wrap_results = false,
        --- give some opacity so we can see the window picker marks.
        winblend = 10,
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
        },
        -- generic_sorter = require('mini.fuzzy').get_telescope_sorter,
        ---@see https://github.com/nvim-telescope/telescope.nvim/issues/522#issuecomment-1107441677
        file_ignore_patterns = { "node_modules/", '.turbo/', 'dist', '.git/' },
        path_display = { 'truncate' },
        -- layout_strategy = 'flex',
        layout_strategy = "vertical",
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
            ['<S-BS>'] = function()
              --- delete previous W
              if vim.fn.mode() == 'n' then return end
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>gEldEa', true, true, true), 'n', false)
            end,
            -- ['<C-e>'] = function() vim.cmd('stopinsert') end,
            -- ["<C-x>"] = false,
            ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
            ['<C-s>'] = actions.cycle_previewers_next,
            ['<C-a>'] = actions.cycle_previewers_prev,
            ['<C-h>'] = function()
              if vim.fn.mode() == 'n' then return end
              -- jump between WORD
              vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<esc>gEa', true, true, true), 'n', false)
            end,
            ['<C-l>'] = function()
              if vim.fn.mode() == 'n' then return end
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
      extensions = {
        ["ui-select"] = {
          require("telescope.themes").get_dropdown {
            -- even more opts
          }
        },
        file_browser = {
          use_fd = true,
          mappings = {
            i = {
              ['<CR>'] = function(prompt_buf)
                local entry_path = action_state.get_selected_entry().Path
                local new_cwd = entry_path:is_dir() and entry_path:absolute() or entry_path:parent():absolute()

                require('userlib.hydra.folder-action').open(new_cwd, prompt_buf)
              end,
            }
          }
        },
        fzf = {
          fuzzy = true,
          override_generic_sorter = false,
          override_file_sorter = false,
          case_mode = 'smart_case',
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
              ['<C-o>'] = function(prompt_bufnr)
                return require('userlib.telescope.picker_keymaps').open_selected_in_window(prompt_bufnr)
              end
            },
            ['n'] = {
              -- your custom normal mode mappings
              ['/'] = function() vim.cmd('startinsert') end,
            },
          },
        },
      },
    }
  end,
})
