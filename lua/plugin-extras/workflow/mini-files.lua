local plug = require('userlib.runtime.pack').plug
local au = require('userlib.runtime.au')

if vim.cfg.mf_tabpage_cwd_paths == nil then
  vim.cfg.mf_tabpage_cwd_paths = {}
end

local map_split = function(buf_id, lhs, direction)
  local rhs = function()
    local MF = require('mini.files')
    local fsentry = MF.get_fs_entry()
    if fsentry.fs_type ~= 'file' then
      return
    end
    -- Make new window and set it as target
    local new_target_window
    vim.api.nvim_win_call(MF.get_target_window(), function()
      vim.cmd(direction .. ' split')
      new_target_window = vim.api.nvim_get_current_win()
    end)

    MF.set_target_window(new_target_window)
    MF.go_in()
    MF.close()
  end

  -- Adding `desc` will result into `show_help` entries
  local desc = 'Split ' .. direction
  vim.keymap.set('n', lhs, rhs, { buffer = buf_id, desc = desc })
end

local filter_show = function(fs_entry)
  local name = fs_entry.name
  return name ~= '.DS_Store' and name ~= '.git' and name ~= '.direnv'
end
local filter_hide = function(fs_entry)
  local name = fs_entry.name
  return not vim.startswith(name, '.') and name ~= '.dotfiles' and name ~= '.config'
end

local get_current_dir = function()
  local MF = require('mini.files')
  local fsentry = MF.get_fs_entry()
  if not fsentry then
    return nil
  end
  return vim.fs.dirname(fsentry.path)
end

return plug({
  enabled = true,
  'echasnovski/mini.files',
  lazy = not vim.cfg.runtime__starts_in_buffer,
  opts = {
    windows = {
      preview = true,
      width_nofocus = 30,
      width_preview = 60,
    },
    options = {
      -- Whether to use for editing directories
      -- Disabled by default in LazyVim because neo-tree is used for that
      use_as_default_explorer = true,
    },
    mappings = {
      go_in_plus = '',
      go_in = 'f',
      go_out = 'F',
      go_out_plus = '',
      reset = '<C-r>',
    },
    content = {
      filter = filter_hide,
      -- sort = function(entries)
      --   -- technically can filter entries here too, and checking gitignore for _every entry individually_
      --   -- like I would have to in `content.filter` above is too slow. Here we can give it _all_ the entries
      --   -- at once, which is much more performant.
      --   local all_paths = table.concat(
      --     vim.tbl_map(function(entry)
      --       return entry.path
      --     end, entries),
      --     '\n'
      --   )
      --   local output_lines = {}
      --   local job_id = vim.fn.jobstart({ 'git', 'check-ignore', '--stdin' }, {
      --     stdout_buffered = true,
      --     on_stdout = function(_, data)
      --       output_lines = data
      --     end,
      --   })
      --
      --   -- command failed to run
      --   if job_id < 1 then
      --     return entries
      --   end
      --
      --   -- send paths via STDIN
      --   vim.fn.chansend(job_id, all_paths)
      --   vim.fn.chanclose(job_id, 'stdin')
      --   vim.fn.jobwait({ job_id })
      --   return require('mini.files').default_sort(vim.tbl_filter(function(entry)
      --     return not vim.tbl_contains(output_lines, entry.path)
      --   end, entries))
      -- end,
    },
  },
  keys = {
    {
      '<leader>fI',
      function()
        local path = nil
        if vim.bo.buftype == 'nofile' then
          path = require('userlib.runtime.utils').get_root()
        else
          path = vim.api.nvim_buf_get_name(0)
        end
        local mf = require('mini.files')
        local is_closed = mf.close()
        if is_closed == true then
          return
        end
        require('mini.files').open(path, true)
      end,
      desc = 'Open mini.files (directory of current file)',
    },
    {
      '<leader>fi',
      function()
        require('mini.files').open(vim.uv.cwd(), true)
      end,
      desc = 'Open mini.files (cwd)',
    },
    {
      '-',
      function()
        local path = nil
        if require('userlib.runtime.buffer').is_empty_buffer(0) then
          path = safe_cwd()
        else
          path = vim.api.nvim_buf_get_name(0)
        end
        local mf = require('mini.files')
        local is_closed = mf.close()
        if is_closed == true then
          return
        end
        require('mini.files').open(path, true)
      end,
      desc = 'Open mini.files (directory of current file)',
    },
  },
  config = function(_, opts)
    local MF = require('mini.files')
    MF.setup(opts)
    vim.schedule(function()
      vim.cmd('hi! link MiniFilesBorder NormalFloat')
    end)
  end,
  init = au.schedule_lazy(function()
    au.define_user_autocmd({
      pattern = 'MiniFilesBufferCreate',
      callback = function(args)
        local MF = require('mini.files')
        local tabpage = vim.api.nvim_get_current_tabpage()
        local bufnr = args.data.buf_id
        local set = require('userlib.runtime.keymap').map_buf_thunk(bufnr)
        local keyopts = {
          noremap = true,
          silent = true,
          nowait = true,
        }
        local show_dotfiles = false
        local toggle_dotfiles = function()
          show_dotfiles = not show_dotfiles
          local new_filter = show_dotfiles and filter_show or filter_hide
          MF.refresh({ content = { filter = new_filter } })
        end

        ---- keys
        set({ 'n', 'v' }, 'd', '"*d', {
          noremap = true,
          silent = true,
          nowait = true,
        })
        set({ 'n', 'v' }, 'D', '"*D', {
          desc = 'Delete to end of line and yank to register d',
          silent = true,
          noremap = true,
        })
        set({ 'v' }, 'x', '"*x', {
          noremap = true,
          silent = true,
          nowait = true,
        })
        set({ 'v' }, 'X', '"*X', {
          noremap = true,
          silent = true,
          nowait = true,
        })
        -- x in normal is yanked to register x.

        set('n', '<BS>', function()
          MF.go_out()
        end)
        set('n', '-', function()
          local lcwd = vim.cfg.mf_tabpage_cwd_paths[tabpage]
          if lcwd ~= nil then
            MF.open(lcwd)
            vim.cfg.mf_tabpage_cwd_paths[tabpage] = nil
          else
            vim.cfg.mf_tabpage_cwd_paths[tabpage] = get_current_dir()
            --- toggle with current and project root.
            MF.open(require('userlib.runtime.utils').get_root(), false)
            MF.trim_left()
          end
        end)
        set('n', 'm', function()
          local fsentry = MF.get_fs_entry()
          if not fsentry then
            return nil
          end
          MF.close()
          require('userlib.mini.clue.folder-action').open(fsentry.path)
        end, keyopts)
        set('n', 'M', function()
          local cwd = get_current_dir()
          require('userlib.hydra.file-action').open(cwd, bufnr, function()
            MF.close()
          end)
        end, keyopts)
        set('n', 'g.', toggle_dotfiles, keyopts)
        set('n', '<ESC>', MF.close, keyopts)
        set('n', '<C-c>', function()
          MF.close()
        end, keyopts)
        set('n', 's', function()
          require('flash').jump({
            search = {
              mode = 'search',
              max_length = 0,
              exclude = {
                function(win)
                  return vim.bo[vim.api.nvim_win_get_buf(win)].filetype ~= 'minifiles'
                end,
              },
            },
            label = { after = { 0, 0 } },
            pattern = '^',
          })
        end, keyopts)

        set('n', '<CR>', function()
          local fsentry = MF.get_fs_entry()
          if fsentry.fs_type ~= 'file' then
            MF.go_in()
            return
          end
          local win_pick = require('window-picker')
          local win_picked = win_pick.pick_window({
            autoselect_one = true,
            -- hint = 'floating-big-letter',
            include_current_win = true,
          })
          if win_picked then
            MF.set_target_window(win_picked)
          end
          MF.go_in()
          MF.close()
        end, keyopts)
        map_split(bufnr, '<C-x>', 'belowright horizontal')
        map_split(bufnr, '<C-v>', 'belowright vertical')

        vim.b.minianimate_disable = true
      end,
    })
    ----- end buflocal settings.
    -- au.define_user_autocmd({
    --   pattern = 'MiniFilesWindowOpen',
    --   callback = function(args)
    -- local win_id = args.data.win_id;
    -- vim.wo[win_id].relativenumber = true
    -- vim.wo[win_id].winblend = 10
    --   end,
    -- })
  end),
})
