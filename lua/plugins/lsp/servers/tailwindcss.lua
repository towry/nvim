local M = {}

local capabilities = require('userlib.lsp.cfg.capbilities')()
capabilities.textDocument.colorProvider = { dynamicRegistration = false }
capabilities.server_capabilities.hoverProvider = false

-- Settings

local attach_colorizer_to_buffer = function(bufnr, opts)
  if vim.b[bufnr].is_big_file then
    return
  end
  local utils = require('userlib.runtime.utils')
  if utils.has_plugin('nvim-colorizer.lua') then
    require('colorizer').attach_to_buffer(bufnr, opts)
  end
end

local on_attach = function(client, bufnr)
  if vim.b[bufnr].is_big_file then
    return
  end
  client.server_capabilities.hoverProvider = false
  if client.server_capabilities.colorProvider then
    -- require('userlib.lsp.cfg.documentcolors').buf_attach(bufnr)
    attach_colorizer_to_buffer(bufnr, {
      mode = 'background',
      css = true,
      names = false,
      tailwind = vim.cfg.editorExtend__colorizer_enable_tailwind_color,
    })
  end
end

local filetypes = { 'html', 'mdx', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'svelte' }

local init_options = {
  userLanguages = {
    eelixir = 'html-eex',
    eruby = 'erb',
  },
}

local settings = {
  tailwindCSS = {
    lint = {
      cssConflict = 'warning',
      invalidApply = 'error',
      invalidConfigPath = 'error',
      invalidScreen = 'error',
      invalidTailwindDirective = 'error',
      invalidVariant = 'error',
      recommendedVariantOrder = 'warning',
    },
    classAttributes = { ':class', 'class', 'className', 'classList', 'ngClass' },
    validate = true,
  },
}

M.on_attach = on_attach
M.filetypes = filetypes
M.capabilities = capabilities
M.settings = settings
M.init_options = init_options

return M
