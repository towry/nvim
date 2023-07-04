local plug = require('libs.runtime.pack').plug
local au = require('libs.runtime.au')

plug({
  {
    'akinsho/toggleterm.nvim',
    dev = false,
    keys = {
      {
        '<leader>//',
        '<cmd>Telescope termfinder find<cr>',
        desc = 'Find terminals with telescope',
      },
      {
        '<leader>gv',
        '<cmd>lua require("libs.terminal.term-git").toggle_tig()<cr>',
        desc = 'Tig commits',
      },
      {
        '<leader>gV',
        '<cmd>lua require("libs.terminal.term-git").toggle_tig_file_history()<cr>',
        desc = "Tig current file history",
      }
    },
    cmd = { 'ToggleTerm', 'TermExec' },
    branch = 'main',
    -- tag = 'v2.2.1',
    config = function()
      -- local au = require('libs.runtime.au')

      require('toggleterm').setup({
        -- size can be a number or function which is passed the current terminal
        size = function(term)
          if term.direction == 'horizontal' then
            return 15
          elseif term.direction == 'vertical' then
            return vim.o.columns * 0.4
          end
        end,
        -- f24 = shift + f12
        open_mapping = nil,
        hide_numbers = true, -- hide the number column in toggleterm buffers
        highlights = {
          -- highlights which map to a highlight group name and a table of it's values
          -- NOTE: this is only a subset of values, any group placed here will be set for the terminal window split
          Normal = {
            link = 'Normal',
          },
          NormalFloat = {
            link = 'Normal',
          },
          FloatBorder = {
            -- guifg = <VALUE-HERE>,
            -- guibg = <VALUE-HERE>,
            link = 'FloatBorder',
          },
        },
        shade_filetypes = { 'none' },
        shade_terminals = true,
        shading_factor = 1,     -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
        start_in_insert = true,
        insert_mappings = true, -- whether or not the open mapping applies in insert mode
        persist_size = false,
        persist_mode = false,
        auto_scroll = false,
        direction = 'horizontal', -- | 'horizontal' | 'window' | 'float',
        close_on_exit = true,     -- close the terminal window when the process exits
        shell = vim.o.shell,      -- change the default shell
        -- This field is only relevant if direction is set to 'float'
        float_opts = {
          -- The border key is *almost* the same as 'nvim_win_open'
          -- see :h nvim_win_open for details on borders however
          -- the 'curved' border is a custom border type
          -- not natively supported but implemented in this plugin.
          border = 'double', -- single/double/shadow/curved
          winblend = 15,
        },
        winbar = {
          enabled = false,
        },
        on_open = function(_term)
          au.do_useraucmd(au.user_autocmds.TermIsOpen_User)
          vim.cmd('startinsert!')
        end,
      })
    end,
    init = function()
      local nvim_buf_set_keymap = vim.keymap.set
      _G._plugin_set_terminal_keymaps = function()
        local buffer = vim.api.nvim_get_current_buf()
        local opts = { noremap = true, buffer = buffer, nowait = true }
        nvim_buf_set_keymap('t', '<C-\\>', [[<C-\><C-n>:ToggleTerm<CR>]], opts)
        -- close term if is in normal mode otherwise enter normal mode.
        nvim_buf_set_keymap('t', '<C-q>', function()
          -- if vim.fn.mode() == 'n' then
          --   return [[<C-\><C-n>:ToggleTerm<CR>]]
          -- end
          vim.cmd('noau stopinsert')
        end, {
          nowait = true,
          noremap = true,
          expr = true,
          buffer = buffer
        })
        --- switch windows
        nvim_buf_set_keymap('t', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
        nvim_buf_set_keymap('t', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
        nvim_buf_set_keymap('t', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
        nvim_buf_set_keymap('t', '<C-l>', [[<C-\><C-n><C-W>l]], opts)

        --- resize
        nvim_buf_set_keymap('t', '<A-h>', [[<C-\><C-n><A-h>]], opts)
        nvim_buf_set_keymap('t', '<A-j>', [[<C-\><C-n><A-j>]], opts)
        nvim_buf_set_keymap('t', '<A-k>', [[<C-\><C-n><A-k>]], opts)
        nvim_buf_set_keymap('t', '<A-l>', [[<C-\><C-n><A-l>]], opts)
      end

      vim.cmd('autocmd! TermOpen term://* lua _plugin_set_terminal_keymaps()')
      vim.keymap.set('n', '<C-\\>', function()
        if vim.tbl_contains({
              'NvimTree',
              'lazy',
            }, vim.bo.filetype) then
          return
        end
        if vim.v.count == 9 then
          vim.cmd([[9ToggleTerm direction=float]])
        else
          vim.cmd(vim.v.count .. [[ToggleTerm direction=horizontal]])
        end
      end, {
        desc = 'toggle term',
        silent = true,
      })

      -- kill all at exits.
      au.define_autocmd('VimLeavePre', {
        group = '_kill_terms_on_leave',
        callback = function()
          require('libs.terminal.toggleterm_kill_all')()
        end,
      })
    end,
  },

  {
    'willothy/flatten.nvim',
    event = {
      au.user_autocmds.TermIsOpen_User,
    },
    enabled = true,
    opts = {
      callbacks = {
        should_block = function(argv)
          -- Note that argv contains all the parts of the CLI command, including
          -- Neovim's path, commands, options and files.
          -- See: :help v:argv

          -- In this case, we would block if we find the `-b` flag
          -- This allows you to use `nvim -b file1` instead of `nvim --cmd 'let g:flatten_wait=1' file1`
          return vim.tbl_contains(argv, "-b")

          -- Alternatively, we can block if we find the diff-mode option
          -- return vim.tbl_contains(argv, "-d")
        end,
        pre_open = function()
          -- Close toggleterm when an external open request is received
          require('toggleterm').toggle(0)
        end,
        post_open = function(bufnr, winnr, ft, is_blocking)
          if is_blocking then
            -- Hide the terminal while it's blocking
            require("toggleterm").toggle(0)
          else
            -- If it's a normal file, just switch to its window
            vim.api.nvim_set_current_win(winnr)
          end
          if ft == 'gitcommit' then
            -- If the file is a git commit, create one-shot autocmd to delete it on write
            -- If you just want the toggleable terminal integration, ignore this bit and only use the
            -- code in the else block
            vim.api.nvim_create_autocmd('BufWritePost', {
              buffer = bufnr,
              once = true,
              callback = function()
                -- This is a bit of a hack, but if you run bufdelete immediately
                -- the shell can occasionally freeze
                vim.defer_fn(function() vim.api.nvim_buf_delete(bufnr, {}) end, 50)
              end,
            })
          end
        end,
        block_end = function()
          -- After blocking ends (for a git commit, etc), reopen the terminal
          require('toggleterm').toggle(0)
        end,
      },
      window = {
        open = 'alternate',
      },
    }
  }
})
