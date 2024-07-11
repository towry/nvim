local req = function(m, s)
    local ok, err = pcall(require, m)
    if not ok and not s then
        vim.schedule(function() vim.notify(err, vim.log.levels.ERROR) end)
    end
    return err
end
-- env requirements
req('nix-env', true)
req('settings_env', true)
req('config.options')
if not vim.g.cfg_empty_argc then
    req('config.autocmds')
end
req('config.lazy')
req('v').nvim_augroup('SetupNvim', {
    event = 'User',
    pattern = 'VeryLazy',
    command = function()
        if vim.g.cfg_empty_argc then
            req('config.autocmds')
        end
        req('config.keymaps')
        req('config.commands')
    end,
}, {
    event = 'UIEnter',
    command = 'colorscheme nordfox',
})
