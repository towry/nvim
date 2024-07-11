local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'

local function prepend_lazy()
    if not vim.uv.fs_stat(lazypath) then
        return false
    end
    vim.opt.rtp:prepend(lazypath)
    return true
end

local function install_lazy_vim()
    print(vim.fn.system({ 'git', 'clone', '--filter=blob:none', 'https://github.com/folke/lazy.nvim.git', lazypath }))
    print(vim.fn.system({ 'git', '-C', lazypath, 'checkout', 'tags/stable' })) -- last stable release
end

local function setup(opts)
    local is_window = jit.os:find('Windows')
    local lazy_opts = {
        spec = {
            { import = "plugins" },
        },
        defaults = { lazy = true },
        dev = { patterns = is_window and {} or {}, path = is_window and '' or '~/workspace/git-repos' },
        install = { missing = true, colorscheme = { 'default' } },
        ui = {
            icons = {
                lazy = ' ',
                plugin = ' ',
            },
        },
        git = {
            timeout = 60,
        },
        concurrency = 8,
        custom_keys = {
            -- open lazygit log
            ['<localleader>l'] = function(plugin)
                require('lazy.util').float_term({ 'lazygit', 'log' }, {
                    cwd = plugin.dir,
                })
            end,
            -- open a terminal for the plugin dir
            ['<localleader>t'] = function(plugin)
                require('lazy.util').float_term(nil, {
                    cwd = plugin.dir,
                })
            end,
        },
        readme = {
            enabled = false,
        },
        profiling = {
            loader = false,
            require = false,
        },
        performance = {
            cache = {
                enabled = true,
            },
            rtp = {
                disabled_plugins = {
                    'gzip',
                    'matchit',
                    'matchparen',
                    'netrwPlugin',
                    'rplugin',
                    'tarPlugin',
                    'tohtml',
                    'tutor',
                    'zipPlugin',
                },
            },
        },
        debug = false,
    }

    local ok = prepend_lazy()

    vim.api.nvim_create_user_command('PrebundlePlugins', function()
        require('userlib.runtime.bundle').run_command({
            main = 'user.config.plugs',
            output = 'user/plugins_bundle.lua',
            glob_dir = { 'user/plugins/*.lua', 'plugin-extras/**/*.lua' },
        })
        if vim.loader then
            vim.loader.reset()
        end
        vim.notify('PrebundlePlugins DONE!')
    end, {})

    if not ok then
        vim.api.nvim_create_user_command('InstallLazyVim', function()
            install_lazy_vim()
            local is_ok_again = prepend_lazy()
            if not is_ok_again then
                vim.notify('... something is wrong when installing the lazy plugin')
                return
            end
            require('lazy').setup(lazy_opts)
            vim.notify('lazy is ready to user')
        end, {})
        -- we want user to decide wether to install or not.
        vim.notify('lazy plugin is not installed, please run :InstallLazyVim command to install')
        return
    end

    require('lazy').setup(lazy_opts)
end

setup()
