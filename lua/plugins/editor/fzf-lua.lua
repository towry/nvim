local M = {}

local function get_last_query()
    local fzflua = require('fzf-lua')
    return vim.trim(fzflua.config.__resume_data.last_query or '')
end

---@param no_buffers? boolean
function M.buffers_or_recent(no_buffers)
    local fzflua = require('fzf-lua')
    local bufopts = {
        filename_first = true,
        sort_lastused = true,
        show_unloaded = false,
        winopts = {
            height = 0.3,
            fullscreen = false,
            preview = {
                hidden = 'hidden',
            },
        },
    }
    local oldfiles_opts = {
        prompt = ' Recent: ',
        cwd = LazyVim.root.cwd(),
        cwd_only = true,
        include_current_session = true,
        winopts = {
            height = 0.3,
            fullscreen = false,
            preview = {
                hidden = 'hidden',
            },
        },
        keymap = {},
    }
    local buffers_actions = {}

    local oldfiles_actions = {
        actions = {
            ['ctrl-e'] = function()
                return fzflua.buffers(vim.tbl_extend('force', {
                    query = get_last_query(),
                }, bufopts, buffers_actions))
            end,
            ['ctrl-f'] = function()
                local query = get_last_query()
                if query == '' or not query then
                    vim.notify('please provide query before switch to find files mode.')
                    return
                end

                M.files({
                    cwd = oldfiles_opts.cwd,
                    query = query,
                })
            end,
        },
    }
    buffers_actions = {
        actions = {
            ['ctrl-e'] = function()
                fzflua.oldfiles(vim.tbl_extend('force', {
                    query = get_last_query(),
                }, oldfiles_opts, oldfiles_actions))
            end,
        },
    }

    local count = #vim.fn.getbufinfo({ buflisted = 1 })
    if no_buffers or count <= 1 then
        --- open recent.
        fzflua.oldfiles(vim.tbl_extend('force', {}, oldfiles_opts, oldfiles_actions))
        return
    end
    local _bo = vim.tbl_extend('force', {}, bufopts, buffers_actions)
    return require('fzf-lua').buffers(_bo)
end

return { {
    'ibhagwan/fzf-lua',
    keys = {
        {
            '<localleader>,',
            M.buffers_or_recent,
            desc = 'Buffers or recent buffers',
        },
        { "<leader>:", "<cmd>FzfLua command_history<cr>", desc = "Command History" },
        { "<c-j>",     "<c-j>",                           ft = "fzf",              mode = "t", nowait = true },
        { "<c-k>",     "<c-k>",                           ft = "fzf",              mode = "t", nowait = true },
    },
    opts = function(_, opts)
        local config = require("fzf-lua.config")
        local actions = require("fzf-lua.actions")

        -- Quickfix
        config.defaults.keymap.fzf["ctrl-q"] = "select-all+accept"
        config.defaults.keymap.fzf["ctrl-u"] = "half-page-up"
        config.defaults.keymap.fzf["ctrl-d"] = "half-page-down"
        config.defaults.keymap.fzf["ctrl-x"] = "jump"
        config.defaults.keymap.fzf["ctrl-f"] = "preview-page-down"
        config.defaults.keymap.fzf["ctrl-b"] = "preview-page-up"
        config.defaults.keymap.builtin["<c-f>"] = "preview-page-down"
        config.defaults.keymap.builtin["<c-b>"] = "preview-page-up"
        -- Toggle root dir / cwd
        config.defaults.actions.files["ctrl-r"] = function(_, ctx)
            local o = vim.deepcopy(ctx.__call_opts)
            o.root = o.root == false
            o.cwd = nil
            o.buf = ctx.__CTX.bufnr
            LazyVim.pick.open(ctx.__INFO.cmd, o)
        end
        config.defaults.actions.files["alt-c"] = config.defaults.actions.files["ctrl-r"]
        config.set_action_helpstr(config.defaults.actions.files["ctrl-r"], "toggle-root-dir")

        local defaults = require("fzf-lua.profiles.max-perf")

        local img_previewer ---@type string[]?
        for _, v in ipairs({
            { cmd = "ueberzug", args = {} },
            { cmd = "chafa",    args = { "{file}", "--format=symbols" } },
            { cmd = "viu",      args = { "-b" } },
        }) do
            if vim.fn.executable(v.cmd) == 1 then
                img_previewer = vim.list_extend({ v.cmd }, v.args)
                break
            end
        end

        return vim.tbl_deep_extend('force', opts, {
            defaults = {
                formatter = 'path.filename_first',
            },
            previewers = {
                builtin = {
                    extensions = {
                        ["png"] = img_previewer,
                        ["jpg"] = img_previewer,
                        ["jpeg"] = img_previewer,
                        ["gif"] = img_previewer,
                        ["webp"] = img_previewer,
                    },
                    ueberzug_scaler = "fit_contain",
                },
            },
            -- Custom LazyVim option to configure vim.ui.select
            ui_select = function(fzf_opts, items)
                return vim.tbl_deep_extend("force", fzf_opts, {
                    prompt = " ",
                    winopts = {
                        title = " " .. vim.trim((fzf_opts.prompt or "Select"):gsub("%s*:%s*$", "")) .. " ",
                        title_pos = "center",
                    },
                }, fzf_opts.kind == "codeaction" and {
                    winopts = {
                        layout = "vertical",
                        -- height is number of items minus 15 lines for the preview, with a max of 80% screen height
                        height = math.floor(math.min(vim.o.lines * 0.8 - 16, #items + 2) + 0.5) + 16,
                        width = 0.5,
                        preview = not vim.tbl_isempty(vim.lsp.get_clients({ bufnr = 0, name = "vtsls" })) and {
                            layout = "vertical",
                            vertical = "down:15,border-top",
                            hidden = "hidden",
                        } or {
                            layout = "vertical",
                            vertical = "down:15,border-top",
                        },
                    },
                } or {
                    winopts = {
                        width = 0.5,
                        -- height is number of items, with a max of 80% screen height
                        height = math.floor(math.min(vim.o.lines * 0.8, #items + 2) + 0.5),
                    },
                })
            end,
            winopts = {
                border = vim.g.cfg_border_style,
                preview = {
                    delay = 150,
                    layout = 'flex',
                    flip_columns = 240,
                    horizontal = 'right:45%',
                    vertical = 'down:40%',
                    winopts = {
                        cursorlineopt = 'line',
                        foldcolumn = 0,
                    },
                },
            },
            fzf_colors = false,
            fzf_opts = {
                ['--ansi'] = '',
                ['--info'] = 'inline',
                ['--height'] = '100%',
                ['--layout'] = 'reverse',
                ['--margin'] = '0%',
                ['--padding'] = '0%',
                ['--border'] = 'none',
                ['--cycle'] = '',
                ['--no-separator'] = '',
            },
            files = {
                cwd_prompt = false,
                actions = {
                    ["alt-i"] = { actions.toggle_ignore },
                    ["alt-h"] = { actions.toggle_hidden },
                },
            },
            grep = {
                actions = {
                    ["alt-i"] = { actions.toggle_ignore },
                    ["alt-h"] = { actions.toggle_hidden },
                },
            },
            lsp = {
                symbols = {
                    symbol_hl = function(s)
                        return "TroubleIcon" .. s
                    end,
                    symbol_fmt = function(s)
                        return s:lower() .. "\t"
                    end,
                    child_prefix = false,
                },
                code_actions = {
                    previewer = vim.fn.executable("delta") == 1 and "codeaction_native" or nil,
                },
            },
        })
    end,
    init = function()
        require('v').nvim_augroup('SetupFzfUiSelect', {
            event = 'User',
            pattern = 'VeryLazy',
            command = function()
                vim.ui.select = function(...)
                    require("lazy").load({ plugins = { "fzf-lua" } })
                    require("fzf-lua").register_ui_select()
                    return vim.ui.select(...)
                end
            end,
        })
    end,
},

    {
        "neovim/nvim-lspconfig",
        opts = function()
            vim.g.cfg_lsp_keymaps = vim.g.cfg_lsp_keymaps or {}
            -- stylua: ignore
            vim.list_extend(vim.g.cfg_lsp_keymaps, {
                { "gd", "<cmd>FzfLua lsp_definitions     jump_to_single_result=true ignore_current_line=true<cr>", desc = "Goto Definition",       has = "definition" },
                { "gr", "<cmd>FzfLua lsp_references      jump_to_single_result=true ignore_current_line=true<cr>", desc = "References",            nowait = true },
                { "gI", "<cmd>FzfLua lsp_implementations jump_to_single_result=true ignore_current_line=true<cr>", desc = "Goto Implementation" },
                { "gy", "<cmd>FzfLua lsp_typedefs        jump_to_single_result=true ignore_current_line=true<cr>", desc = "Goto T[y]pe Definition" },
            })
        end,
    },
}
