-- local del = vim.keymap.del
local set = vim.keymap.set
local Insert = 'i'
local Visual = 'v'
-- local Command = 'c'
-- local OperatorPending = 'o'
local Normal = 'n'

-- del('n', '<S-h>')
-- del('n', '<S-l>')

local maps = {
    {
        Insert,
        'jj',
        '<ESC>',
        {
            desc = 'Leave insert with jj',
            silent = true,
            nowait = true,
            noremap = true,
        },
    },
    {
        Visual,
        '<C-w>',
        'B',
        {
            desc = '<C-w> in insert starts selection mode and this continue select in visual mode',
        },
    },
    {
        Insert,
        '<C-w>',
        function()
            -- check current is float
            if vim.api.nvim_win_get_config(0).relative ~= '' then
                return '<C-w>'
            end
            return '<left><C-o>v'
        end,
        {
            desc = 'Enhance <c-w> in insert',
            remap = false,
            expr = true,
        },
    },
    {
        Normal,
        '<C-c><C-k>',
        function()
            local tabs_count = vim.fn.tabpagenr('$')
            if tabs_count <= 1 then
                vim.cmd('silent! hide | echo "hide current window"')
                return
            end
            --- get current tab's window count
            local win_count = require('v').tab_win_count()
            if win_count <= 1 then
                local choice = vim.fn.confirm('Close last window in tab?', '&Yes\n&No', 2)
                if choice == 2 then
                    return
                end
                return
            end
            vim.cmd('silent! hide | echo "hide current window"')
        end,
        {
            desc = 'Kill current window',
        },
    },
    {
        Normal,
        '<C-c><C-d>',
        function()
            if vim.fn.exists('&winfixbuf') == 1 and vim.api.nvim_get_option_value('winfixbuf', { win = 0 }) then
                vim.cmd('hide')
                return
            end

            LazyVim.ui.bufremove()
        end,
        {
            desc = 'Kill current buffer',
        },
    },
    {
        Normal,
        '<C-c><C-c>',
        function()
            if vim.fn.exists('&winfixbuf') == 1 and vim.api.nvim_get_option_value('winfixbuf', { win = 0 }) then
                vim.cmd('hide')
                return
            end
            if vim.api.nvim_win_get_config(vim.api.nvim_get_current_win()).relative ~= '' then
                --- float window
                vim.cmd('close')
                return
            end
            vim.cmd([[echo "Unshow buffer " .. bufnr("%")]])
            LazyVim.ui.bufremove(0)
        end,
        {
            desc = 'Unshow current buffer',
        },
    },
    {
        Normal,
        'H',
        function()
            local has_folded = vim.fn.foldclosed('.') > -1
            local is_at_first_non_whitespace_char_of_line = (vim.fn.col('.') - 1) ==
                vim.fn.match(vim.fn.getline('.'), '\\S')

            if is_at_first_non_whitespace_char_of_line and not has_folded then
                return 'za'
            end
            if vim.fn.foldclosed('.') == -1 then
                return '^'
            end
        end,
        {
            desc = 'Move to first non-blank character of the line',
            expr = true,
            remap = false,
        }
    },
    {
        Normal,
        'L',
        function()
            if vim.fn.foldclosed('.') > -1 then
                return 'zo'
            else
                return '$'
            end
        end,
        {
            expr = true,
            remap = false,
            desc = 'Move to last non-blank character of the line',
        }
    },
    {
        Normal,
        '<A-q>',
        function()
            local current_win_is_qf = vim.bo.filetype == 'qf'
            if current_win_is_qf then
                vim.cmd('wincmd p')
            else
                -- focus on qf window
                vim.cmd('copen')
            end
        end,
        {
            desc = 'Switch between quickfix window and previous window',
        }
    },
    {
        Normal,
        '<leader>np',
        function()
            local reg = vim.v.register or '"'
            vim.cmd(':put ' .. reg)
            vim.cmd([[normal! `[v`]=]])
        end,
        {
            expr = false,
            noremap = true,
            silent = false,
            desc = 'Paste in next line and format',
        }
    },
    {
        Normal,
        '<leader>nP',
        function()
            local reg = vim.v.register or '"'
            vim.cmd(':put! ' .. reg)
            vim.cmd([[normal! `[v`]=]])
        end,
        {
            expr = false,
            noremap = true,
            silent = false,
            desc = 'Paste in above line and format',
        }
    },
    {
        Normal,
        '<leader>nv',
        '`[v`]',
        {
            expr = false,
            noremap = true,
            silent = false,
            desc = 'Visual select pasted content',
        }
    },

}
do
    if not vim.g.cfg_inside.git then return end
    set('v', 'dp', [[:<C-u>'<,'>diffput<cr>]], {
        desc = 'Diffput in visual',
        silent = true,
    })
    set('v', 'do', [[:<C-u>'<,'>diffget<cr>]], {
        desc = 'Diffget in visual',
        silent = true,
    })
    set('n', '<localleader>w', ':w|cq', { desc = '[Git mergetool] Prepare write and exit safe' })
    set('n', '<localleader>c', ':cq 1', { desc = '[Git mergetool] Prepare to abort' })
end
do
    if not vim.tbl_contains({ 'coq', 'native' }, vim.g.cfg_cmp_provider) then return end
    local replace_termcode = vim.api.nvim_replace_termcodes
    --- wait: https://github.com/neovim/neovim/issues/25714
    --- wait: https://github.com/neovim/neovim/pull/27339
    local keys = {
        ['cr'] = replace_termcode('<CR>', true, true, false),
        -- close pum after completion
        ['ctrl-y'] = replace_termcode('<C-y>', true, true, false),
        ['ctrl-j'] = replace_termcode('<C-j>', true, true, false),
        ['ctrl-y_cr'] = replace_termcode('<C-y><CR>', true, true, false),
        ['space'] = replace_termcode('<Space>', true, true, false),
        ['ctrl-z'] = replace_termcode('<C-z>', true, true, false),
        ['bs-ctrl-z'] = replace_termcode('<C-h><C-z>', true, true, false),
    }
    -- set({ 'c' }, '<', '<', { noremap = true, silent = false })
    set({ 'c' }, [[<Tab>]], function()
        if vim.fn.pumvisible() ~= 0 then
            return '<C-n>'
        else
            return '<C-z>'
        end
    end, { expr = true, silent = false, noremap = true })
    --- back a whitespace and then trigger completion.
    set('c', [[<C-h>]], function()
        if vim.fn.pumvisible() ~= 0 then
            return '<C-n>'
        end
        return keys['bs-ctrl-z']
    end, { expr = true, silent = false, noremap = true })
    ---- native cmp keys
    -- Move inside completion list with <TAB>
    set({ 'i', 's' }, [[<Tab>]], function()
        if vim.fn.pumvisible() ~= 0 then
            return '<C-n>'
        elseif vim.snippet.active({ direction = 1 }) then
            --- must use schedule becase edit must occures in next loop.
            vim.schedule(function()
                vim.snippet.jump(1)
            end)
        else
            if package.loaded['neotab'] then
                -- final fallback
                return [[<Plug>(neotab-out)]]
            else
                return '<Tab>'
            end
        end
    end, { expr = true, silent = false })

    set({ 'i', 's' }, [[<CR>]], function()
        if vim.fn.pumvisible() ~= 0 then
            local item_selected = vim.fn.complete_info()['selected'] ~= -1
            return item_selected and keys['ctrl-y'] or keys['ctrl-y_cr']
        end
        return keys['cr']
    end, { expr = true, silent = true, noremap = true })

    set({ 'i', 's' }, [[<S-Tab>]], function()
        if vim.fn.pumvisible() ~= 0 then
            return '<C-p>'
        elseif vim.snippet.active({ direction = -1 }) then
            vim.schedule(function()
                vim.snippet.jump(-1)
            end)
        else
            return '<S-Tab>'
        end
    end, { expr = true, silent = false })

    set({ 'i' }, '<C-j>', function()
        local trigger_ai = function()
            -- trigger ai
            if vim.b._copilot then
                vim.fn['copilot#Suggest']()
            elseif vim.fn.exists('*codeium#Complete') == 1 then
                vim.fn['codeium#Complete']()
            end
        end

        -- accept ai or completion selection.
        if vim.fn.pumvisible() ~= 0 then
            local item_selected = vim.fn.complete_info()['selected'] ~= -1
            if item_selected then
                return keys['ctrl-j']
            end
        end

        local V = require('v');
        if V.has_ai_suggestions() and V.has_ai_suggestion_text() then
            if vim.b._copilot then
                vim.fn.feedkeys(vim.fn['copilot#Accept'](), 'i')
            elseif vim.b._codeium_completions then
                vim.fn.feedkeys(vim.fn['codeium#Accept'](), 'i')
            end
        else
            trigger_ai()
        end
    end, {
        silent = false,
        expr = true,
        noremap = true,
        desc = 'Complete AI or nvim completion',
    })
end

do
    for _, v in ipairs(maps) do
        set(v[1], v[2], v[3], v[4])
    end
end

-------------------------------------------------------------------------------
--- setup keymap on terminal
vim.g.set_terminal_keymaps = vim.schedule_wrap(function(bufnr)
    local nvim_buf_set_keymap = vim.keymap.set
    local buffer = bufnr or vim.api.nvim_get_current_buf()
    local opts = { noremap = true, buffer = buffer, nowait = true, silent = true }

    if not vim.api.nvim_buf_is_valid(buffer) then
        return
    end

    --- prevent <C-z> behavior in all terminals in neovim
    nvim_buf_set_keymap('t', '<C-z>', '<NOP>', opts)

    -- do not bind below keys in fzf-lua terminal window.
    if vim.tbl_contains({ 'yazi', 'fzf' }, vim.bo.filetype) then
        return
    end

    nvim_buf_set_keymap('t', '<esc><esc>', function()
        vim.cmd.stopinsert()
    end, opts)
    nvim_buf_set_keymap({ 'n', 't' }, '<F2>', function()
        if not vim.b.osc7_dir then
            return
        end
        vim.cmd('stopinsert')

        vim.schedule(function()
            local choice = vim.fn.confirm('Cd into: ' .. vim.b.osc7_dir .. ' ?', '&Yes\n&No', 2)
            if choice == 1 then
                vim.cmd('Cdin ' .. vim.b.osc7_dir)
                return
            end
            vim.cmd.startinsert()
        end)
    end, opts)

    nvim_buf_set_keymap('n', 'q', [[:startinsert<cr>]], opts)
    -- nvim_buf_set_keymap('t', '<ESC>', [[<C-\><C-n>]], opts)
    --- switch windows
    nvim_buf_set_keymap('t', '<C-\\><C-h>', [[<C-\><C-n><C-W>h]], opts)
    nvim_buf_set_keymap('t', '<C-\\><C-j>', [[<C-\><C-n><C-W>j]], opts)
    nvim_buf_set_keymap('t', '<C-\\><C-k>', [[<C-\><C-n><C-W>k]], opts)
    nvim_buf_set_keymap('t', '<C-\\><C-l>', [[<C-\><C-n><C-W>l]], opts)

    --- resize
    -- nvim_buf_set_keymap('t', '<A-h>', [[<C-\><C-n><A-h>]], opts)
    -- nvim_buf_set_keymap('t', '<A-j>', [[<C-\><C-n><A-j>]], opts)
    -- nvim_buf_set_keymap('t', '<A-k>', [[<C-\><C-n><A-k>]], opts)
    -- nvim_buf_set_keymap('t', '<A-l>', [[<C-\><C-n><A-l>]], opts)
end)
