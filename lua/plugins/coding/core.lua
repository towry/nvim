return {
    -- auto completion
    {
        "hrsh7th/nvim-cmp",
        enabled = vim.g.cfg_cmp_provider == 'cmp',
        version = false, -- last release is way too old
        event = "InsertEnter",
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
        },
        -- Not all LSP servers add brackets when completing a function.
        -- To better deal with this, LazyVim adds a custom option to cmp,
        -- that you can configure. For example:
        --
        -- ```lua
        -- opts = {
        --   auto_brackets = { "python" }
        -- }
        -- ```
        opts = function()
            vim.api.nvim_set_hl(0, "CmpGhostText", { link = "Comment", default = true })
            local cmp = require("cmp")
            local cmp_mod = require('plugins.coding.mod.cmp')
            local defaults = require("cmp.config.default")()
            local auto_select = true
            return {
                auto_brackets = {}, -- configure any filetype to auto add brackets
                completion = {
                    completeopt = "menu,menuone,noinsert" .. (auto_select and "" or ",noselect"),
                },
                preselect = auto_select and cmp.PreselectMode.Item or cmp.PreselectMode.None,
                mapping = cmp.mapping.preset.insert({
                    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
                    ["<C-f>"] = cmp.mapping.scroll_docs(4),
                    ["<C-Space>"] = cmp.mapping.complete(),
                    ["<CR>"] = cmp_mod.confirm({ select = auto_select }),
                    ["<C-y>"] = cmp_mod.confirm({ select = true }),
                    ["<S-CR>"] = cmp_mod.confirm({ behavior = cmp.ConfirmBehavior.Replace }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                    ["<C-CR>"] = function(fallback)
                        cmp.abort()
                        fallback()
                    end,
                }),
                sources = cmp.config.sources({
                    { name = "nvim_lsp" },
                    { name = "path" },
                }, {
                    { name = "buffer" },
                }),
                formatting = {
                    format = function(entry, item)
                        local icons = require('plugins.mod.icons').kinds
                        if icons[item.kind] then
                            item.kind = icons[item.kind] .. item.kind
                        end

                        local widths = {
                            abbr = vim.g.cmp_widths and vim.g.cmp_widths.abbr or 40,
                            menu = vim.g.cmp_widths and vim.g.cmp_widths.menu or 30,
                        }

                        for key, width in pairs(widths) do
                            if item[key] and vim.fn.strdisplaywidth(item[key]) > width then
                                item[key] = vim.fn.strcharpart(item[key], 0, width - 1) .. "…"
                            end
                        end

                        return item
                    end,
                },
                experimental = {
                    ghost_text = {
                        hl_group = "CmpGhostText",
                    },
                },
                sorting = defaults.sorting,
            }
        end,
    },

    -- snippets
    {
        "nvim-cmp",
        dependencies = {
            {
                "garymjr/nvim-snippets",
                opts = {
                    friendly_snippets = true,
                },
                dependencies = { "rafamadriz/friendly-snippets" },
            },
        },
        opts = function(_, opts)
            local cmp_mod = require('plugins.coding.mod.cmp')
            opts.snippet = {
                expand = function(item)
                    return cmp_mod.expand(item.body)
                end,
            }
            if require('plugins.mod.utils').has("nvim-snippets") then
                table.insert(opts.sources, { name = "snippets" })
            end
        end,
        keys = {
            {
                "<Tab>",
                function()
                    return vim.snippet.active({ direction = 1 }) and "<cmd>lua vim.snippet.jump(1)<cr>" or "<Tab>"
                end,
                expr = true,
                silent = true,
                mode = { "i", "s" },
            },
            {
                "<S-Tab>",
                function()
                    return vim.snippet.active({ direction = -1 }) and "<cmd>lua vim.snippet.jump(-1)<cr>" or "<S-Tab>"
                end,
                expr = true,
                silent = true,
                mode = { "i", "s" },
            },
        },
    },

    -- auto pairs
    {
        "echasnovski/mini.pairs",
        event = "VeryLazy",
        opts = {
            modes = { insert = true, command = true, terminal = false },
            -- skip autopair when next character is one of these
            skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
            -- skip autopair when the cursor is inside these treesitter nodes
            skip_ts = { "string" },
            -- skip autopair when next character is closing pair
            -- and there are more closing pairs than opening pairs
            skip_unbalanced = true,
            -- better deal with markdown code blocks
            markdown = true,
        },
        keys = {
            {
                "<leader>up",
                function()
                    vim.g.minipairs_disable = not vim.g.minipairs_disable
                end,
                desc = "Toggle Auto Pairs",
            },
        },
        config = function(_, opts)
            local pairs = require("mini.pairs")
            pairs.setup(opts)
            local open = pairs.open
            pairs.open = function(pair, neigh_pattern)
                if vim.fn.getcmdline() ~= "" then
                    return open(pair, neigh_pattern)
                end
                local o, c = pair:sub(1, 1), pair:sub(2, 2)
                local line = vim.api.nvim_get_current_line()
                local cursor = vim.api.nvim_win_get_cursor(0)
                local next = line:sub(cursor[2] + 1, cursor[2] + 1)
                local before = line:sub(1, cursor[2])
                if opts.markdown and o == "`" and vim.bo.filetype == "markdown" and before:match("^%s*``") then
                    return "`\n```" .. vim.api.nvim_replace_termcodes("<up>", true, true, true)
                end
                if opts.skip_next and next ~= "" and next:match(opts.skip_next) then
                    return o
                end
                if opts.skip_ts and #opts.skip_ts > 0 then
                    local ok, captures = pcall(vim.treesitter.get_captures_at_pos, 0, cursor[1] - 1,
                        math.max(cursor[2] - 1, 0))
                    for _, capture in ipairs(ok and captures or {}) do
                        if vim.tbl_contains(opts.skip_ts, capture.capture) then
                            return o
                        end
                    end
                end
                if opts.skip_unbalanced and next == c and c ~= o then
                    local _, count_open = line:gsub(vim.pesc(pair:sub(1, 1)), "")
                    local _, count_close = line:gsub(vim.pesc(pair:sub(2, 2)), "")
                    if count_close > count_open then
                        return o
                    end
                end
                return open(pair, neigh_pattern)
            end
        end,
    },

    -- comments
    {
        "folke/ts-comments.nvim",
        event = "VeryLazy",
        opts = {},
    },

    -- Better text-objects
    {
        "echasnovski/mini.ai",
        event = "VeryLazy",
        opts = function()
            local function ai_indent(ai_type)
                local spaces = (" "):rep(vim.o.tabstop)
                local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                local indents = {} ---@type {line: number, indent: number, text: string}[]

                for l, line in ipairs(lines) do
                    if not line:find("^%s*$") then
                        indents[#indents + 1] = { line = l, indent = #line:gsub("\t", spaces):match("^%s*"), text = line }
                    end
                end

                local ret = {} ---@type (Mini.ai.region | {indent: number})[]

                for i = 1, #indents do
                    if i == 1 or indents[i - 1].indent < indents[i].indent then
                        local from, to = i, i
                        for j = i + 1, #indents do
                            if indents[j].indent < indents[i].indent then
                                break
                            end
                            to = j
                        end
                        from = ai_type == "a" and from > 1 and from - 1 or from
                        to = ai_type == "a" and to < #indents and to + 1 or to
                        ret[#ret + 1] = {
                            indent = indents[i].indent,
                            from = { line = indents[from].line, col = ai_type == "a" and 1 or indents[from].indent + 1 },
                            to = { line = indents[to].line, col = #indents[to].text },
                        }
                    end
                end

                return ret
            end
            local function ai_buffer(ai_type)
                local start_line, end_line = 1, vim.fn.line("$")
                if ai_type == "i" then
                    -- Skip first and last blank lines for `i` textobject
                    local first_nonblank, last_nonblank = vim.fn.nextnonblank(start_line), vim.fn.prevnonblank(end_line)
                    -- Do nothing for buffer with all blanks
                    if first_nonblank == 0 or last_nonblank == 0 then
                        return { from = { line = start_line, col = 1 } }
                    end
                    start_line, end_line = first_nonblank, last_nonblank
                end

                local to_col = math.max(vim.fn.getline(end_line):len(), 1)
                return { from = { line = start_line, col = 1 }, to = { line = end_line, col = to_col } }
            end

            local ai = require("mini.ai")
            return {
                n_lines = 500,
                custom_textobjects = {
                    o = ai.gen_spec.treesitter({ -- code block
                        a = { "@block.outer", "@conditional.outer", "@loop.outer" },
                        i = { "@block.inner", "@conditional.inner", "@loop.inner" },
                    }),
                    f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function
                    c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),       -- class
                    t = { "<([%p%w]-)%f[^<%w][^<>]->.-</%1>", "^<.->().*()</[^/]->$" },           -- tags
                    d = { "%f[%d]%d+" },                                                          -- digits
                    e = {                                                                         -- Word with case
                        { "%u[%l%d]+%f[^%l%d]", "%f[%S][%l%d]+%f[^%l%d]", "%f[%P][%l%d]+%f[^%l%d]", "^[%l%d]+%f[^%l%d]" },
                        "^().*()$",
                    },
                    i = ai_indent,                                             -- indent
                    g = ai_buffer,                                             -- buffer
                    u = ai.gen_spec.function_call(),                           -- u for "Usage"
                    U = ai.gen_spec.function_call({ name_pattern = "[%w_]" }), -- without dot in function name
                },
            }
        end,
    },

    {
        "folke/lazydev.nvim",
        ft = "lua",
        cmd = "LazyDev",
        opts = {
            library = {
                { path = "luvit-meta/library", words = { "vim%.uv" } },
                { path = "LazyVim",            words = { "LazyVim" } },
                { path = "lazy.nvim",          words = { "LazyVim" } },
            },
        },
    },
    -- Manage libuv types with lazy. Plugin will never be loaded
    { "Bilal2453/luvit-meta", lazy = true },
    -- Add lazydev source to cmp
    {
        "hrsh7th/nvim-cmp",
        opts = function(_, opts)
            table.insert(opts.sources, { name = "lazydev", group_index = 0 })
        end,
    },
}
