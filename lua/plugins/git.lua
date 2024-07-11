local V = require('v')
local keymap_cmd = V.keymap_cmd

return {
  {
    'mbbill/undotree',
    keys = {
      {
        '<leader>bu',
        '<cmd>:UndotreeToggle<cr>',
        desc = 'Toggle undo tree',
      },
    },
    cmd = { 'UndotreeToggle', 'UndotreeHide', 'UndotreeShow' },
    init = function()
      local g = vim.g
      g.undotree_WindowLayout = 1
      g.undotree_SetFocusWhenToggle = 1
      g.undotree_SplitWidth = 30
      g.undotree_DiffAutoOpen = 1
    end,
  },

  {
    'junegunn/gv.vim',
    dependencies = {
      'tpope/vim-fugitive',
    },
    cmd = 'GV',
    config = false,
    keys = {
      {
        '<leader>gz',
        '<cmd>GV<cr>',
        desc = 'Git logs with GV',
      },
    },
  },
  {
    'tpope/vim-fugitive',
    dependencies = {
      'tpope/vim-dispatch',
      'stevearc/overseer.nvim',
    },
    keys = {
      {
        '<leader>g1',
        function()
          local res = vim
            .system({
              'git',
              'log',
              '--oneline',
              '--date=relative',
              '--abbrev',
              '--no-color',
              '--pretty=format:%s (%an)',
              '-3',
            }, { text = true })
            :wait()
          if res.code == 0 then
            vim.notify('   \n' .. res.stdout, vim.log.levels.INFO)
          else
            vim.notify(res.stderr, vim.log.levels.ERROR)
          end
        end,
        desc = 'Emit HEAD commit info',
      },
      { '<leader>g.', ':Git', desc = 'Fugitive start :Git' },
      { '<leader>gm', ':Git merge', desc = 'Fugitive start git merge' },
      {
        '<leader>gg',
        ':Git | resize +10<cr>',
        desc = 'Fugitive Git',
      },
      {
        '<leader>gG',
        ':tab Git<cr>',
        desc = 'Fugitive Git in tab',
      },
      {
        '<leader>ga',
        keymap_cmd([[OverDispatch! git add -- % && git diff --cached --check || echo Conflict founds || exit 1]]),
        desc = '!Git add current',
      },
      {
        '<leader>gtd',
        keymap_cmd([[tab Gdiffsplit]]),
        desc = 'Git diff in tab',
      },
      {
        '<leader>gA',
        keymap_cmd([[OverDispatch! git add .]]),
        desc = '!Git add all',
      },
      {
        '<leader>gp',
        keymap_cmd([[exec "OverDispatch! git push --force-with-lease origin " .. FugitiveHead()]]),
        desc = 'Git push',
      },
      {
        '<leader>gi',
        keymap_cmd([[OverDispatch! git wip]]),
        desc = 'Create wip commit',
      },
      {
        '<leader>gu',
        function()
          vim.g.escape_cmd = 'pclose'
          vim.cmd('OverDispatch git pull --ff origin ' .. vim.fn.FugitiveHead())
        end,
        desc = 'Git pull',
        silent = false,
      },
      {
        '<leader>gs',
        function()
          vim.cmd([[tab Git diff HEAD]])
          -- vim.cmd([[:lua vim.bo.syntax="diff"]])
        end,
        desc = 'Git status with Fugitive on HEAD',
        silent = false,
      },
      {
        '<leader>gl',
        function()
          -- https://github.com/niuiic/git-log.nvim/blob/main/lua/git-log/init.lua
          local file_name = vim.api.nvim_buf_get_name(0)
          local line_range = V.get_range()
          local cmd =
            string.format([[vert Git log --max-count=100 -L %s,%s:%s]], line_range[1], line_range[2], file_name)
          vim.print(cmd)
          vim.cmd(cmd)
        end,
        desc = 'View log for selected chunks',
        mode = { 'v', 'x' },
      },
      {
        '<leader>gl',
        function()
          local vcount = vim.v.count
          local max_count_arg = ''
          if vcount ~= 0 and vcount ~= nil and vcount > 0 then
            max_count_arg = string.format('--max-count=%s', vcount)
          end
          vim.cmd(
            'vert Git log -P '
              .. max_count_arg
              .. ' --oneline --date=format:"%Y-%m-%d %H:%M" --pretty=format:"%h %ad: %s - %an" -- %'
          )
        end,
        desc = 'Git show current file history',
      },
      {
        -- git log with -p for current buffer. with limits for performance.
        '<leader>gL',
        function()
          local vcount = vim.v.count
          local max_count_arg = ''
          if vcount ~= 0 and vcount ~= nil and vcount > 0 then
            max_count_arg = string.format('--max-count=%s', vcount)
          end
          vim.cmd(string.format([[Git log %s -p -m --first-parent -P -- %s]], max_count_arg, vim.fn.expand('%')))
        end,
        desc = 'Git show current file history with diff',
      },
      {
        '<leader>gd',
        keymap_cmd([[Git diff -- %]]),
        desc = 'Diff current file',
      },
      {
        '<leader>gD',
        keymap_cmd([[Git diff -- %]]),
        desc = 'Diff current file unified',
      },
      {
        '<leader>gb',
        keymap_cmd([[Git blame -n --date=short --color-lines --show-stats %]]),
        desc = 'Git blame current file',
      },
      {
        '<leader>gb',
        function()
          local file_name = vim.api.nvim_buf_get_name(0)
          local line_range = V.get_range()
          vim.cmd(
            string.format(
              [[Git blame -n --date=short --color-lines -L %s,%s %s]],
              line_range[1],
              line_range[2],
              file_name
            )
          )
        end,
        mode = 'x',
        desc = 'Git blame current file with range',
      },
      {
        '<leader>gx',
        '<cmd>silent OverDispatch! git add -- % && git diff --cached --check --quiet || git commit --amend --no-edit<cr>',
        desc = 'Git amend all',
      },
      {
        'gj',
        function()
          require('userlib.mini.clue.git-commit').open(function(prefix)
            if not prefix then
              return
            end
            vim.ui.input({
              prompt = prefix,
            }, function(input)
              -- if input is trimmed empty
              if vim.trim(input or '') == '' then
                vim.notify('Empty commit message', vim.log.levels.ERROR)
                return
              end

              input = prefix .. ' ' .. input

              vim.cmd(string.format('OverDispatch! git commit -m "%s"', input))
            end)
          end)
        end,
        desc = 'Git commit',
        noremap = true,
        silent = true,
      },
      {
        '<leader>gc',
        function()
          -- use vim.ui.input to write commit message and then commit with the
          -- message.
          vim.ui.input({
            prompt = 'Commit message: ',
          }, function(input)
            -- if input is trimmed empty
            if vim.trim(input or '') == '' then
              vim.notify('Empty commit message', vim.log.levels.ERROR)
              return
            end

            if require('userlib.git.utils').is_head_wip_commit() then
              vim.cmd(string.format('OverDispatch! git commit --amend --no-edit -m "%s"', input))
            else
              vim.cmd(string.format('OverDispatch! git commit -m "%s"', input))
            end
          end)
        end,
        desc = 'Git commit',
      },
    },
    cmd = {
      'G',
      'Git',
      'Gread',
      'Gwrite',
      'Ggrep',
      'GMove',
      'GDelete',
      'GBrowse',
      'Gdiffsplit',
      'Gvdiffsplit',
      'Gedit',
      'Gsplit',
      'Grevert',
      'Grebase',
      'Gpedit',
      'Gclog',
    },
    init = function()
      vim.api.nvim_create_autocmd('BufWinEnter', {
        pattern = '*fugitive://*',
        group = vim.api.nvim_create_augroup('_plug_fug_auto_jump_', { clear = true }),
        callback = function()
          vim.schedule(function()
            local ft = vim.bo.filetype
            if ft ~= 'fugitive' then
              return
            end
            vim.cmd('normal! gg5j')
          end)
        end,
      })
    end,
  },
}
