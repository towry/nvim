local M = {}

M.setup = function()
  local colors = require('ty.contrib.ui').colors()
  local spectre_extension = {
    sections = {
      lualine_a = { 'mode' },
    },
    filetypes = { 'spectre_panel' },
  }
  local present, lualine = pcall(require, 'lualine')

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
      component_separators = '│',
      section_separators = { left = '', right = '' },
      disabled_filetypes = { winbar = { 'lazy', 'alpha' }, statusline = { 'dashboard', 'lazy', 'alpha' } },
    },
    tabline = {
      lualine_a = {
        {
          'buffers',
          mode = 1,
          show_modified_status = true,
          symbols = {
            modified = '',
            alternate_file = ' ',
            directory = ' ',
          },
        },
      },
      lualine_b = { '' },
      lualine_c = { '' },
      lualine_x = {},
      lualine_y = {},
      lualine_z = { '' },
    },
    sections = {
      lualine_a = {
        { 'mode' },
        {
          function()
            local has_modified = false
            for _, buf in ipairs(vim.api.nvim_list_bufs()) do
              if vim.api.nvim_buf_get_option(buf, 'modified') then
                has_modified = true
                break
              end
            end
            vim.b['has_modified_file'] = has_modified
            local icon = has_modified and ' ' or ' '
            return icon .. #vim.fn.getbufinfo({ buflisted = 1 })
          end,

          separator = { right = '' },

          color = function()
            if vim.b['has_modified_file'] then
              return {
                bg = '#C20505',
                fg = '#ffffff',
              }
            end
          end,
        },
      },
      lualine_b = {
        'branch',
        'diff',
        'diagnostics',
        {
          function()
            local key = require('grapple').key()
            return ' [' .. key .. ']'
          end,
          cond = function() return require('ty.core.utils').has_plugin('grapple.nvim') and require('grapple').exists() end,
        },
        'searchcount',
      },
      -- filename is displayed by the incline.
      lualine_c = {
        {
          'filename',
          symbols = {
            modified = '🐷',
            newfile = '🐼',
          },
          file_status = true,
          newfile_status = true,
          path = 1,
          color = function()
            return {
              fg = colors.lualine_filename_fg,
            }
          end,
        },
      },
      lualine_x = {
        {
          'copilot',
        },
        'encoding',
        {
          'fileformat',
        },
        { 'filetype', colored = true, icon_only = true },
      },
      lualine_y = { 'progress' },
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
