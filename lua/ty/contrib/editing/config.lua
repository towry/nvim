-- configurations for editing.
-- sections: { 'format', 'lsp', }

local servers = require('ty.core.lsp').servers

local M = {
  --- enable visual multi cursor?
  ---@type boolean
  visual_multi_cursor = false,
}

--- confirgurations for format.
M.format = {
  ---@type boolean
  format_on_save = true,
  format_on_save_on_filetypes = {
    'vue',
    'typescript',
    'typescriptreact',
    'javascriptreact',
    'javascript',
    'css',
    'lua',
    'html',
    'scss',
  }
}

--- configurations for lsp.
M.lsp = {
  --- language servers that we wnat to use.
  ---@type table
  ---@see ty.core.lsp.servers
  lang_servers = { servers.lua, servers.typescript, servers.css, servers.json, servers.html, servers.bash },
}

M.lspsaga = {
  enable = false,
}

return M
