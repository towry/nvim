local treesitter_parsers_path = vim.fn.stdpath('data') .. '/site'

return {
    {
        'nvim-treesitter/nvim-treesitter',
        branch = 'main',
        build = ':TSUpdate',
        event = 'VeryLazy',
        cond = not vim.g.cfg_inside.git,
        opts = {
            install_dir = treesitter_parsers_path,
            ensure_install = {
                'diff',
                'vim',
                'vimdoc',
                'bash',
                'fish',
                'css',
                'html',
                'javascript',
                'json',
                'jsonc',
                'jsdoc',
                'lua',
                'python',
                'regex',
                'rust',
                'scss',
                'tsx',
                'typescript',
                'yaml',
                'markdown',
                'markdown_inline',
                'nim',
            },
            auto_install = true,
            ignore_install = { 'comment' },
        },
        config = function(opts)
            vim.opt.runtimepath:prepend(treesitter_parsers_path)

            require('nvim-treesitter').setup(opts)
            vim.treesitter.language.register('tsx', 'typescriptreact')
            vim.treesitter.language.register('markdown', 'mdx')
        end,
        init = function()
            vim.api.nvim_create_augroup('treesitter_start', { clear = true })
            vim.api.nvim_create_autocmd('User', {
                group = 'treesitter_start',
                pattern = 'TreeSitterStart',
                callback = function(ctx)
                    -- FIXME: tree sitter indent not working well on some ft like nix.
                    local buf = ctx.data.bufnr
                    if vim.b[buf].indentexpr == 0 then
                        return
                    end
                    vim.bo[buf].indentexpr = [[v:lua.require('nvim-treesitter').indentexpr()]]
                end,
            })
        end,
    },


    {
        'JoosepAlviste/nvim-ts-context-commentstring',
        enabled = false,
        cond = not vim.g.cfg_inside.git,
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        },
        lazy = true,
        opts = {
            enable_autocmd = false,
        },
    }
}
