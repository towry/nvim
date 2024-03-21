-- debugger and runner.
-- local cmdstr = require('userlib.runtime.keymap').cmdstr
local au = require('userlib.runtime.au')
local pack = require('userlib.runtime.pack')
local libutils = require('userlib.runtime.utils')

---- dap
pack.plug({
  'mfussenegger/nvim-dap',
  dependencies = {
    { 'theHamsta/nvim-dap-virtual-text' },
    { 'rcarriga/nvim-dap-ui' },
  },
  config = function()
    local utils = require('userlib.runtime.utils')
    local present_dapui, dapui = pcall(require, 'dapui')
    local present_dap, dap = pcall(require, 'dap')
    local present_virtual_text, dap_vt = pcall(require, 'nvim-dap-virtual-text')
    local _, shade = pcall(require, 'shade')

    if not present_dapui or not present_dap or not present_virtual_text then
      return
    end

    -- ╭──────────────────────────────────────────────────────────╮
    -- │ DAP Virtual Text Setup                                   │
    -- ╰──────────────────────────────────────────────────────────╯
    dap_vt.setup({
      enabled = true, -- enable this plugin (the default)
      enabled_commands = true, -- create commands DapVirtualTextEnable, DapVirtualTextDisable, DapVirtualTextToggle, (DapVirtualTextForceRefresh for refreshing when debug adapter did not notify its termination)
      highlight_changed_variables = true, -- highlight changed values with NvimDapVirtualTextChanged, else always NvimDapVirtualText
      highlight_new_as_changed = false, -- highlight new variables in the same way as changed variables (if highlight_changed_variables)
      show_stop_reason = true, -- show stop reason when stopped for exceptions
      commented = false, -- prefix virtual text with comment string
      only_first_definition = true, -- only show virtual text at first definition (if there are multiple)
      all_references = false, -- show virtual text on all all references of the variable (not only definitions)
      filter_references_pattern = '<module', -- filter references (not definitions) pattern when all_references is activated (Lua gmatch pattern, default filters out Python modules)
      -- Experimental Features:
      virt_text_pos = 'eol', -- position of virtual text, see `:h nvim_buf_set_extmark()`
      all_frames = false, -- show virtual text for all stack frames not only current. Only works for debugpy on my machine.
      virt_lines = false, -- show virtual lines instead of virtual text (will flicker!)
      virt_text_win_col = nil, -- position the virtual text at a fixed window column (starting from the first text column) ,
    })

    -- ╭──────────────────────────────────────────────────────────╮
    -- │ DAP UI Setup                                             │
    -- ╰──────────────────────────────────────────────────────────╯
    dapui.setup({
      icons = { expanded = '▾', collapsed = '▸' },
      mappings = {
        -- Use a table to apply multiple mappings
        expand = { '<CR>', '<2-LeftMouse>' },
        open = 'o',
        remove = 'd',
        edit = 'e',
        repl = 'r',
        toggle = 't',
      },
      -- Expand lines larger than the window
      -- Requires >= 0.7
      expand_lines = vim.fn.has('nvim-0.7'),
      -- Layouts define sections of the screen to place windows.
      -- The position can be "left", "right", "top" or "bottom".
      -- The size specifies the height/width depending on position. It can be an Int
      -- or a Float. Integer specifies height/width directly (i.e. 20 lines/columns) while
      -- Float value specifies percentage (i.e. 0.3 - 30% of available lines/columns)
      -- Elements are the elements shown in the layout (in order).
      -- Layouts are opened in order so that earlier layouts take priority in window sizing.
      layouts = {
        {
          elements = {
            -- Elements can be strings or table with id and size keys.
            { id = 'scopes', size = 0.25 },
            'breakpoints',
            'stacks',
            'watches',
          },
          size = 40, -- 40 columns
          position = 'left',
        },
        {
          elements = {
            'repl',
            'console',
          },
          size = 0.25, -- 25% of total lines
          position = 'bottom',
        },
      },
      floating = {
        max_height = nil, -- These can be integers or a float between 0 and 1.
        max_width = nil, -- Floats will be treated as percentage of your screen.
        border = 'single', -- Border style. Can be "single", "double" or "rounded"
        mappings = {
          close = { 'q', '<Esc>' },
        },
      },
      windows = { indent = 1 },
      render = {
        max_type_length = nil, -- Can be integer or nil.
      },
    })

    -- ╭──────────────────────────────────────────────────────────╮
    -- │ DAP Setup                                                │
    -- ╰──────────────────────────────────────────────────────────╯
    dap.set_log_level('TRACE')

    -- Automatically open UI
    dap.listeners.after.event_initialized['dapui_config'] = function()
      dapui.open()
      shade.toggle()
    end
    dap.listeners.before.event_terminated['dapui_config'] = function()
      dapui.close()
      shade.toggle()
    end
    dap.listeners.before.event_exited['dapui_config'] = function()
      dapui.close()
      shade.toggle()
    end

    -- Enable virtual text
    vim.g.dap_virtual_text = true

    -- ╭──────────────────────────────────────────────────────────╮
    -- │ Icons                                                    │
    -- ╰──────────────────────────────────────────────────────────╯
    -- TODO: deprecated api.
    vim.fn.sign_define('DapBreakpoint', { text = '🟥', texthl = '', linehl = '', numhl = '' })
    vim.fn.sign_define('DapStopped', { text = '⭐️', texthl = '', linehl = '', numhl = '' })

    -- ╭──────────────────────────────────────────────────────────╮
    -- │ Adapters                                                 │
    -- ╰──────────────────────────────────────────────────────────╯
    -- NODE / TYPESCRIPT
    dap.adapters.node2 = {
      type = 'executable',
      command = 'node',
      args = { vim.fn.stdpath('data') .. '/mason/packages/node-debug2-adapter/out/src/nodeDebug.js' },
    }

    -- Chrome
    dap.adapters.chrome = {
      type = 'executable',
      command = 'node',
      args = { vim.fn.stdpath('data') .. '/mason/packages/chrome-debug-adapter/out/src/chromeDebug.js' },
    }

    -- TODO: move to ftplugin.
    dap.configurations.javascript = {
      {
        type = 'node2',
        request = 'launch',
        program = '${file}',
        cwd = utils.get_root(),
        sourceMaps = true,
        protocol = 'inspector',
        console = 'integratedTerminal',
      },
    }

    dap.configurations.javascript = {
      {
        type = 'chrome',
        request = 'attach',
        program = '${file}',
        cwd = utils.get_root(),
        sourceMaps = true,
        protocol = 'inspector',
        port = 9222,
        webRoot = '${workspaceFolder}',
      },
    }

    dap.configurations.javascriptreact = {
      {
        type = 'chrome',
        request = 'attach',
        program = '${file}',
        cwd = utils.get_root(),
        sourceMaps = true,
        protocol = 'inspector',
        port = 9222,
        webRoot = '${workspaceFolder}',
      },
    }

    dap.configurations.typescriptreact = {
      {
        type = 'chrome',
        request = 'attach',
        program = '${file}',
        cwd = utils.get_root(),
        sourceMaps = true,
        protocol = 'inspector',
        port = 9222,
        webRoot = '${workspaceFolder}',
      },
    }
  end,
})

pack.plug({
  {
    'nvim-neotest/neotest',
    enabled = vim.cfg.edit__use_coc,
    optional = true,
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      vim.list_extend(opts.adapters, {
        require('neotest-vim-test')({
          allow_file_types = {
            'rust',
            'typescript',
            'javascript',
            'typescriptreact',
            'javascriptreact',
          },
        }),
      })
      return opts
    end,
  },
})

---neotest
pack.plug({
  cmd = 'Neotest',
  'rcarriga/neotest',
  dependencies = {
    'nvim-neotest/nvim-nio',
    'nvim-lua/plenary.nvim',
    'antoinemadec/FixCursorHold.nvim',
    -- lang:js
    'haydenmeade/neotest-jest',
    -- lang:rust
    -- https://nexte.st/
    -- 'rouge8/neotest-rust',
  },
  init = au.schedule_lazy(function()
    au.on_filetype('neotest-output', 'setlocal wrap')

    require('userlib.legendary').register('neotest', function(lg)
      lg.funcs({
        {
          function()
            require('neotest').summary.toggle()
          end,
          description = 'Neotest toggle summary',
        },
        {
          function()
            require('neotest').run.run()
          end,
          description = 'Neotest run',
        },
        {
          function()
            require('neotest').stop()
          end,
          description = 'Neotest stop',
        },
        -- run current file.
        {
          function()
            require('neotest').run.run(vim.fn.expand('%'))
          end,
          description = 'Neotest run current file',
        },
        {
          function()
            require('neotest').run({ strategy = 'dap' })
          end,
          description = 'Debug the nearest test',
        },
      })
    end)
  end),
  opts = function()
    return {
      adapters = {
        require('neotest-jest')({
          jestCommand = 'pnpm test --',
          env = { CI = true },
          cwd = function(path)
            return require('userlib.runtime.utils').get_root()
          end,
        }),
      },

      diagnostic = {
        enabled = true,
      },
      floating = {
        border = 'single',
        max_height = 0.6,
        max_width = 0.9,
      },
      highlights = {
        adapter_name = 'NeotestAdapterName',
        border = 'NeotestBorder',
        dir = 'NeotestDir',
        expand_marker = 'NeotestExpandMarker',
        failed = 'NeotestFailed',
        file = 'NeotestFile',
        focused = 'NeotestFocused',
        indent = 'NeotestIndent',
        namespace = 'NeotestNamespace',
        passed = 'NeotestPassed',
        running = 'NeotestRunning',
        skipped = 'NeotestSkipped',
        test = 'NeotestTest',
      },
      icons = {
        child_indent = '│',
        child_prefix = '├',
        collapsed = '─',
        expanded = '╮',
        failed = '✖',
        final_child_indent = ' ',
        final_child_prefix = '╰',
        non_collapsible = '─',
        passed = '✔',
        running = '󰦖',
        skipped = 'ⓙ',
        unknown = '?',
      },
      output = {
        enabled = true,
        open_on_run = true,
      },
      run = {
        enabled = true,
      },
      quickfix = {
        enabled = true,
        open = false,
      },
      status = {
        enabled = true,
      },
      strategies = {
        integrated = {
          height = 40,
          width = 120,
        },
      },
      summary = {
        enabled = true,
        expand_errors = true,
        follow = true,
        mappings = {
          attach = 'a',
          expand = { '<CR>', '<2-LeftMouse>' },
          expand_all = 'e',
          jumpto = 'i',
          output = 'o',
          run = 'r',
          short = 'O',
          stop = 'u',
        },
      },
    }
  end,
  config = function(_, opts)
    local present, neotest = pcall(require, 'neotest')
    if not present then
      return
    end

    if opts.adapters then
      local adapters = {}
      for name, config in pairs(opts.adapters or {}) do
        if type(name) == 'number' then
          if type(config) == 'string' then
            config = require(config)
          end
          adapters[#adapters + 1] = config
        elseif config ~= false then
          local adapter = require(name)
          if type(config) == 'table' and not vim.tbl_isempty(config) then
            local meta = getmetatable(adapter)
            if adapter.setup then
              adapter.setup(config)
            elseif meta and meta.__call then
              adapter(config)
            else
              error('Adapter ' .. name .. ' does not support setup')
            end
          end
          adapters[#adapters + 1] = adapter
        end
      end
      opts.adapters = adapters
    end

    neotest.setup(opts)
  end,
})

pack.plug({
  'nvim-neotest/neotest-vim-test',
  event = { 'BufRead' },
  dependencies = {
    'nvim-neotest/neotest',
    {
      'vim-test/vim-test',
      cmd = {
        'TestNearest',
        'TestClass',
        'TestFile',
        'TestSuite',
        'TestLast',
        'TestVisit',
      },
      init = au.schedule_lazy(function()
        vim.g['test#neovim#start_normal'] = 1
        vim.g['test#toggleterm#start_normal'] = 1
        vim.g['test#neovim_sticky#start_normal'] = 0
        vim.g['test#strategy'] = 'toggleterm'
        vim.g['test#neovim_sticky#kill_previous'] = 1
        vim.g['test#preserve_screen'] = 0
        vim.g['test#neovim_sticky#reopen_window'] = 1
        vim.g['test#echo_command'] = 0

        require('userlib.legendary').register('vim-test', function(lg)
          lg.funcs({
            {
              vim.schedule_wrap(function()
                local mark = 't'
                local _, error = pcall(vim.api.nvim_command, ([['%s]]):format(mark))
                if error then
                  return
                end
                vim.schedule(function()
                  vim.cmd('TestNearest')
                end)
              end),
              description = 'vim test: test mark t position',
            },
          })
          lg.commands({
            {
              ':TestNearest',
              description = 'vim test: test nearest',
            },
            {
              ':TestFile',
              description = 'vim test: test file',
            },
            {
              ':TestLast',
              description = 'vim test: test last',
            },
            {
              ':TestVisit',
              description = 'vim test: test last visit',
            },
          })
        end)
      end),
    },
  },
  enabled = vim.cfg.edit__use_coc,
})

---overseer|task runner
pack.plug({
  -- https://github.com/stevearc/overseer.nvim
  'stevearc/overseer.nvim',
  dependencies = {
    'mfussenegger/nvim-dap',
  },
  cmd = {
    'OverseerRestartLast',
    'Grep',
    'OverseerRun',
    'OverseerOpen',
    'OverseerToggle',
    'OverseerClose',
    'OverseerSaveBundle',
    'OverseerLoadBundle',
    'OverseerDeleteBundle',
    'OverseerRunCmd',
    'OverseerInfo',
    'OverseerBuild',
    'OverseerQuickAction',
    'OverseerTaskAction',
    'OverseerClearCache',
  },
  keys = {
    -- {
    --   '<leader>gp',
    --   function()
    --     local overseer = require('overseer')
    --     local task = overseer.new_task({
    --       cmd = [[echo "git push..." ; git push]],
    --       cwd = vim.cfg.runtime__starts_cwd,
    --       components = {
    --         'on_exit_set_status',
    --         { 'on_output_quickfix', open = false, open_height = 8 },
    --         { 'on_complete_notify_with_key', key = 'git_push', annote = 'Git' },
    --       },
    --     })
    --     vim.notify('git push', vim.log.levels.INFO, {
    --       key = 'git_push',
    --       annote = 'Git',
    --     })
    --     task:start()
    --   end,
    --   desc = 'Git push',
    -- },
    { '<leader>roo', '<cmd>OverseerToggle<cr>', desc = 'Toggle' },
    { '<leader>ror', '<cmd>OverseerRun<cr>', desc = 'Run' },
    { '<leader>roR', '<cmd>OverseerRunCmd<cr>', desc = 'Run shell cmd' },
    { '<leader>roc', '<cmd>OverseerClose<cr>', desc = 'Close' },
    { '<leader>ros', '<cmd>OverseerSaveBundle<cr>', desc = 'Save bundle' },
    { '<leader>rol', '<cmd>OverseerLoadBundle<cr>', desc = 'Load bundle' },
    { '<leader>rod', '<cmd>OverseerDeleteBundle<cr>', desc = 'Delete bundle' },
    {
      '<leader>rov',
      '<cmd>lua require("userlib.overseers.utils").open_vsplit_last()<cr>',
      desc = 'Open last in vsplit',
    },
    {
      '<leader>roq',
      '<cmd>OverseerQuickAction<cr>',
      desc = 'Run an action on the most recent task, or the task under the cursor',
    },
    { '<leader>roT', '<cmd>OverseerTaskAction<cr>', desc = 'Select a task to run an action on' },
    { '<leader>roC', '<cmd>OverseerClearCache<cr>', desc = 'Clear cache' },
  },
  opts = {
    -- https://github.com/stevearc/overseer.nvim/blob/master/doc/reference.md#setup-options
    -- strategy = "terminal",
    strategy = 'terminal',
    templates = { 'builtin' },
    auto_detect_success_color = true,
    dap = true,
    task_list = {
      max_width = { 100, 0.6 },
      min_width = { 50, 0.4 },
      direction = 'right',
      bindings = {
        ['<C-t>'] = '<CMD>OverseerQuickAction open tab<CR>',
        ['='] = 'IncreaseDetail',
        ['-'] = 'DecreaseDetail',
        ['<C-y>'] = 'ScrollOutputUp',
        ['<C-n>'] = 'ScrollOutputDown',
        ['<C-k>'] = false,
        ['<C-j>'] = false,
        ['<C-l>'] = false,
        ['<C-h>'] = false,
      },
    },
    task_launcher = {},
  },
  config = function(_, opts)
    vim.g.plugin_overseer_loaded = 1
    local overseer = require('overseer')
    local overseer_vscode_variables = require('overseer.template.vscode.variables')
    local precalculate_vars = overseer_vscode_variables.precalculate_vars

    overseer_vscode_variables.precalculate_vars = function()
      local tbl = precalculate_vars()
      tbl['workspaceFolder'] = vim.cfg.runtime__starts_cwd
      tbl['workspaceRoot'] = vim.cfg.runtime__starts_cwd
      tbl['fileWorkspaceFolder'] = libutils.get_root()
      tbl['workspaceFolderBasename'] = vim.fs.basename(vim.cfg.runtime__starts_cwd)
      return tbl
    end

    overseer.setup(opts)

    --- add variable for vscode tasks.
    -- overseer.add_template_hook({ module = 'vscode', }, function(task_defn, _util)
    -- end)

    -- if has_dap then
    --   require("dap.ext.vscode").json_decode = require("overseer.util").decode_json
    -- end
    vim.api.nvim_create_user_command('OverseerRestartLast', function()
      local tasks = overseer.list_tasks({ recent_first = true })
      if vim.tbl_isempty(tasks) then
        vim.notify('No tasks found', vim.log.levels.WARN)
      else
        overseer.run_action(tasks[1], 'restart')
      end
    end, {})
  end,
  init = au.schedule_lazy(function()
    require('userlib.legendary').register('overseer', function(lg)
      lg.commands({
        {
          'OverseerRun',
          description = 'Overseer run',
        },
        {
          'OverseerClose',
          description = 'Overseer close',
        },
        {
          'OverseerOpen',
          description = 'Overseer open',
        },
        {
          'OverseerToggle',
          description = 'Overseer toggle',
        },
      })

      lg.funcs({
        {
          function()
            local overseer = require('overseer')
            local tasks = overseer.list_tasks({ recent_first = true })
            if vim.tbl_isempty(tasks) then
              vim.notify('No tasks found', vim.log.levels.WARN)
            else
              overseer.run_action(tasks[1], 'restart')
            end
          end,
          description = 'Overseer restart last',
        },
      })
    end)
  end),
})

pack.plug({
  enabled = false,
  'michaelb/sniprun',
  build = 'sh ./install.sh',
  cmd = {
    'SnipRun',
    'SnipInfo',
    'SnipReset',
    'SnipClose',
    'SnipReplMemoryClean',
    'SnipLive',
  },
  keys = {
    {
      '<leader>rf',
      '<cmd>lua require("userlib.hydra.sniprun").open()<cr>',
      { desc = 'Open sniprun', mode = { 'n' } },
    },
  },
  -- https://michaelb.github.io/sniprun/sources/README.html#installation
  opts = {
    display = {
      'Classic', --# display results in the command-line  area
      'VirtualTextOk', --# display ok results as virtual text (multiline is shortened)
    },
  },
  init = function()
    vim.keymap.set('v', 'f', '<cmd>lua require("userlib.hydra.sniprun").open_visual()<cr>', {
      desc = 'Open sniprun',
    })
  end,
})

pack.plug({
  --- hex view tool.
  'mattn/vim-xxdcursor',
  ft = 'xxd',
})
