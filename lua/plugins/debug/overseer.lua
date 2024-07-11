return {
    {
        -- https://github.com/stevearc/overseer.nvim
        'stevearc/overseer.nvim',
        cmd = {
            'OverseerRestartLast',
            'OverseerRun',
            'OverseerOpen',
            'OverseerToggle',
            'OverseerClose',
            'OverseerSaveBundle',
            'OverseerLoadBundle',
            'OverseerDeleteBundle',
            'OverseerRunCmd',
            -- Show infos like checkhealth
            'OverseerInfo',
            'OverseerBuild',
            -- run action on last.
            'OverseerQuickAction',
            -- select running task and perf action: kill or restart etc.
            'OverseerTaskAction',
            'OverseerClearCache',
        },
        keys = {
            { '<localleader>o;', '<cmd>OverseerRestartLast<cr>',  desc = 'Restart last task' },
            { '<localleader>oo', '<cmd>OverseerToggle<cr>',       desc = 'Toggle' },
            { '<localleader>or', '<cmd>OverseerRun<cr>',          desc = 'Run' },
            { '<localleader>oR', '<cmd>OverseerRunCmd<cr>',       desc = 'Run shell cmd' },
            { '<localleader>oc', '<cmd>OverseerClose<cr>',        desc = 'Close' },
            { '<localleader>os', '<cmd>OverseerSaveBundle<cr>',   desc = 'Save bundle' },
            { '<localleader>ol', '<cmd>OverseerLoadBundle<cr>',   desc = 'Load bundle' },
            { '<localleader>od', '<cmd>OverseerDeleteBundle<cr>', desc = 'Delete bundle' },
            {
                '<localleader>ov',
                '<cmd>lua require("userlib.overseers.utils").open_vsplit_last()<cr>',
                desc = 'Open last in vsplit',
            },
            {
                '<localleader>oq',
                '<cmd>OverseerQuickAction<cr>',
                desc = 'Run an action on the most recent task, or the task under the cursor',
            },
            {
                '<localleader>ot',
                function()
                    local ovutils = require('userlib.overseers.utils')
                    ovutils.run_action_on_tasks({
                        unique = true,
                        recent_first = true,
                    })
                end,
                desc = 'List tasks',
            },
            -- { '<localleader>ot', '<cmd>OverseerTaskAction<cr>', desc = 'Select a task to run an action on' },
            { '<localleader>oC', '<cmd>OverseerClearCache<cr>', desc = 'Clear cache' },
        },
        opts = {
            -- https://github.com/stevearc/overseer.nvim/blob/master/doc/reference.md#setup-options
            -- strategy = "terminal",
            strategy = 'terminal',
            templates = { 'builtin' },
            auto_detect_success_color = true,
            dap = false,
            task_list = {
                default_detail = 2,
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
            form = {
                border = 'single',
            },
            confirm = {
                border = 'single',
            },
            task_win = {
                border = 'single',
            },
            help_win = {
                border = 'single',
            },
            task_launcher = {},
        },
        config = function(_, opts)
            local overseer = require('overseer')
            local overseer_vscode_variables = require('overseer.template.vscode.variables')
            local precalculate_vars = overseer_vscode_variables.precalculate_vars

            overseer_vscode_variables.precalculate_vars = function()
                local tbl = precalculate_vars()
                tbl['workspaceFolder'] = vim.g.cfg_root_cwd
                tbl['workspaceRoot'] = vim.g.cfg_root_cwd
                tbl['fileWorkspaceFolder'] = vim.uv.cwd()
                tbl['workspaceFolderBasename'] = vim.fs.basename(vim.g.cfg_root_cwd)
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
        init = function()
        end,
    },
    {
        "nvim-neotest/neotest",
        optional = true,
        opts = function(_, opts)
            opts = opts or {}
            opts.consumers = opts.consumers or {}
            opts.consumers.overseer = require("neotest.consumers.overseer")
        end,
    },
    {
        "mfussenegger/nvim-dap",
        optional = true,
        opts = function()
            require("overseer").enable_dap()
        end,
    },
}
