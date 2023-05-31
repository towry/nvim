local M = {}


M.setup = function()
  require('ty.core.options').setup_statusline()
  local auto_format_disabled = require('ty.contrib.editing.lsp.formatting').auto_format_disabled
  local Buffer               = require('ty.core.buffer')
  local terms                = require('ty.contrib.statusline.lualine.terms_component')
  -- local colors = require('ty.contrib.ui').colors()
  local spectre_extension    = {
    sections = {
      lualine_a = { 'mode' },
    },
    filetypes = { 'spectre_panel' },
  }
  local present, lualine     = pcall(require, 'lualine')

  if not present then
    Ty.NOTIFY('lualine not installed')
    return
  end

  lualine.setup({
    extensions = {
      spectre_extension,
      'toggleterm',
      'nvim-tree',
    },
    options = {
      theme = require('ty.contrib.ui').plugins.lualine.theme,
      globalstatus = true,
      -- component_separators = '│',
      component_separators = '',
      section_separators = { left = '', right = '' },
      disabled_filetypes = { winbar = { 'lazy', 'alpha' }, statusline = { 'dashboard', 'lazy', 'alpha' } },
    },
    winbar = {
      lualine_a = {
        {
          'filename',
          path = 1,
          symbols = {
            modified = '',
            readonly = '',
          }
        }
      },
    },
    inactive_winbar = {
      lualine_a = {
        {
          'filename',
          path = 1,
          symbols = {
            modified = '',
            readonly = '',
          }
        }
      },
    },
    sections = {
      lualine_a = {
        {
          function()
            local unsaved_count = #Buffer.unsaved_list()
            local has_modified = unsaved_count > 0
            local unsaved_count_text = unsaved_count > 0 and (':' .. unsaved_count) or ''
            vim.b['has_modified_file'] = has_modified
            local icon = has_modified and ' ' or ' '
            return icon .. #vim.fn.getbufinfo({ buflisted = 1 }) .. unsaved_count_text
          end,
          color = function()
            if vim.b['has_modified_file'] then
              return {
                bg = '#C20505',
                fg = '#ffffff',
              }
            end
          end,
        },
        { 'mode' },
        {
          terms,
        }
      },
      lualine_b = {
        {
          'branch',
          icon = ""
        },
        {
          function()
            -- local key = require('grapple').key()
            -- return ' [' .. key .. ']'
            local idx = require('harpoon.mark').status()
            return ' [' .. idx .. ']'
          end,
          cond = function()
            local idx = require('harpoon.mark').status()
            return idx and idx ~= ''
          end
          -- cond = function() return require('ty.core.utils').has_plugin('grapple.nvim') and require('grapple').exists() end,
        },
        {
          function()
            local bufnr = vim.api.nvim_get_current_buf()
            return require("hbac.state").is_pinned(bufnr) and "📍" or ""
          end,
          color = { fg = "#ef5f6b", gui = "bold" },
        },
        'searchcount',
      },
      -- filename is displayed by the incline.
      lualine_c = { 'diff', 'diagnostics', },
      lualine_x = {
        {
          'copilot',
        },
        {
          'encoding',
          cond = function()
            return vim.opt.fileencoding and vim.opt.fileencoding:get() ~= 'utf-8'
          end
        },
        {
          function()
            local icon = ' '
            if auto_format_disabled() then
              icon = ' '
            end
            return string.format('%s%s', icon, vim.b[0].formatter_name)
          end,
          cond = function()
            return vim.b[0].formatter_name ~= nil
          end
        },
        {
          'fileformat',
          cond = function()
            return not vim.tbl_contains({ 'unix', 'mac' }, vim.bo.fileformat)
          end,
        },
        { 'filetype', colored = true, icon_only = true },
      },
      lualine_y = { 'filesize', 'progress' },
      lualine_z = { { 'location', separator = { right = '' }, left_padding = 0 } },
    },
    inactive_sections = {
      lualine_a = {},
      lualine_b = {},
      lualine_c = { '' },
      lualine_x = { 'location' },
      lualine_y = {},
      lualine_z = {},
    },
  })
end

return M
