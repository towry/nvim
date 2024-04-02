local plug = require('userlib.runtime.pack').plug
local icons = require('userlib.icons')

plug({
  'nvim-neo-tree/neo-tree.nvim',
  branch = 'main', -- HACK: force neo-tree to checkout `main` for initial v3 migration since default branch has changed
  dependencies = { 'MunifTanjim/nui.nvim' },
  cmd = 'Neotree',
  keys = {
    {
      '<leader>ft',
      '<cmd>Neotree position=right toggle=true<cr>',
      desc = 'Toggle explore tree',
    },
    {
      '\\',
      function()
        if vim.bo.buftype == '' then
          vim.t.neotree_last_buf = vim.api.nvim_get_current_buf()
        else
          vim.t.neotree_last_buf = nil
        end
        if vim.bo.filetype == 'neo-tree' then
          vim.cmd('wincmd p')
        else
          vim.cmd([[Neotree position=right action=focus reveal=false]])
        end
      end,
      desc = 'Toggle explore tree',
    },
    {
      '|',
      function()
        local cwd = vim.cfg.runtime__starts_cwd or safe_cwd()
        vim.cmd(
          string.format([[Neotree source=buffers position=right action=focus toggle=true reveal=true dir=%s]], cwd)
        )
      end,
      desc = 'Toggle buffers',
    },
    {
      '<leader>f.',
      '<cmd>Neotree reveal float<cr>',
      desc = 'Locate current file in tree',
    },
  },
  init = function()
    vim.g.neo_tree_remove_legacy_commands = true
  end,
  opts = function()
    return {
      auto_clean_after_session_restore = true,
      close_if_last_window = true,
      sources = { 'filesystem', 'buffers', 'git_status' },
      source_selector = {
        winbar = true,
        content_layout = 'start',
        sources = {
          { source = 'filesystem', display_name = icons.folder .. 'File' },
          { source = 'buffers', display_name = icons.buffer .. 'Bufs' },
          -- { source = 'git_status', display_name = icons.git .. 'Git' },
          -- { source = 'diagnostics', display_name = icons.wrench .. 'Diagnostic' },
        },
      },
      default_component_configs = {
        indent = { padding = 0 },
      },
      commands = {
        system_open = function(state)
          (vim.ui.open)(state.tree:get_node():get_id())
        end,
        reveal_last_buf = function()
          if not vim.t.neotree_last_buf or not vim.api.nvim_buf_is_valid(vim.t.neotree_last_buf) then
            vim.notify('no active buffer to reveal', vim.log.levels.INFO)
            return
          end
          local reveal_file = vim.api.nvim_buf_get_name(vim.t.neotree_last_buf)
          if reveal_file == '' then
            return
          else
            local f = io.open(reveal_file, 'r')
            if f then
              f.close(f)
            else
              return
            end
          end

          require('neo-tree.command').execute({
            source = 'filesystem', -- OPTIONAL, this is the default value
            reveal_file = reveal_file, -- path to file or folder to reveal
          })
        end,
        parent_or_close = function(state)
          local node = state.tree:get_node()
          if (node.type == 'directory' or node:has_children()) and node:is_expanded() then
            state.commands.toggle_node(state)
          else
            require('neo-tree.ui.renderer').focus_node(state, node:get_parent_id())
          end
        end,
        child_or_open = function(state)
          local node = state.tree:get_node()
          if node.type == 'directory' or node:has_children() then
            if not node:is_expanded() then -- if unexpanded, expand
              state.commands.toggle_node(state)
            else -- if expanded and has children, seleect the next child
              require('neo-tree.ui.renderer').focus_node(state, node:get_child_ids()[1])
            end
          else -- if not a directory just open it
            -- state.commands.open(state)
          end
        end,
        copy_selector = function(state)
          local node = state.tree:get_node()
          local filepath = node:get_id()
          local filename = node.name
          local modify = vim.fn.fnamemodify

          local vals = {
            ['BASENAME'] = modify(filename, ':r'),
            ['EXTENSION'] = modify(filename, ':e'),
            ['FILENAME'] = filename,
            ['PATH (CWD)'] = modify(filepath, ':.'),
            ['PATH (HOME)'] = modify(filepath, ':~'),
            ['PATH'] = filepath,
            ['URI'] = vim.uri_from_fname(filepath),
          }

          local options = vim.iter(vim.tbl_keys(vals)):filter(function(val)
            return vals[val] ~= ''
          end)

          if vim.tbl_isempty(options) then
            vim.notify('No values to copy', vim.log.levels.WARN)
            return
          end
          table.sort(options)
          vim.ui.select(options, {
            prompt = 'Choose to copy to clipboard:',
            format_item = function(item)
              return ('%s: %s'):format(item, vals[item])
            end,
          }, function(choice)
            local result = vals[choice]
            if result then
              vim.notify(('Copied: `%s`'):format(result))
              vim.fn.setreg('+', result)
            end
          end)
        end,
        -- run action on folder
        action_in_dir = function(state)
          local node = state.tree:get_node()
          local path = node:get_id()
          local cwd = node.type == 'directory' and path or vim.fn.fnamemodify(path, ':h')

          require('userlib.mini.clue.folder-action').open(cwd)
        end,
        unfocus = function()
          vim.cmd('wincmd p')
        end,
      },
      window = {
        width = 40,
        auto_expand_width = true,
        mapping_options = {
          noremap = true,
          nowait = false,
        },
        mappings = {
          ['[b'] = 'prev_source',
          [']b'] = 'next_source',
          ['m'] = 'action_in_dir',
          ['w'] = 'open_with_window_picker',
          O = 'system_open',
          Y = 'copy_selector',
          h = 'parent_or_close',
          l = 'child_or_open',
          o = 'open',
          e = false,
          E = 'toggle_auto_expand_width',
          q = 'unfocus',
          Q = 'close_window',
        },
        fuzzy_finder_mappings = { -- define keymaps for filter popup window in fuzzy_finder_mode
          ['<C-j>'] = 'move_cursor_down',
          ['<C-k>'] = 'move_cursor_up',
        },
      },
      filesystem = {
        follow_current_file = { enabled = false },
        hijack_netrw_behavior = 'open_current',
        use_libuv_file_watcher = true,
        bind_to_cwd = false,
        group_empty_dirs = true,
        window = {
          mappings = {
            ['-'] = 'navigate_up',
            ['.'] = 'reveal_last_buf',
          },
        },
      },
      buffers = {
        bind_to_cwd = false,
        follow_current_file = {
          enabled = true, -- This will find and focus the file in the active buffer every time
          --              -- the current file is changed while the tree is open.
          leave_dirs_open = false, -- `false` closes auto expanded dirs, such as with `:Neotree reveal`
        },
      },
      event_handlers = {
        {
          event = 'neo_tree_buffer_enter',
          handler = function(_)
            vim.opt_local.signcolumn = 'auto'
          end,
        },
        {
          event = 'neo_tree_window_after_open',
          handler = function(args) end,
        },
        {
          event = 'neo_tree_window_before_close',
          handler = function(args) end,
        },
      },
    }
  end,
})
