require('v')
require('config.options')
-- env requirements
pcall(function()
    require('nix-env')
    require('settings_env')
end)
if not vim.g.cfg_empty_argc then
    require('config.autocmds')
end
require('config.lazy')
require('v').nvim_augroup('SetupNvim', {
    event = 'User',
    pattern = 'VeryLazy',
    command = function()
        if vim.g.cfg_empty_argc then
            require('config.autocmds')
        end
        require('config.keymaps')
        require('config.commands')
    end,
}, {
    event = 'UIEnter',
    command = 'colorscheme nordfox',
})
