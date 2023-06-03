local custom_fname = require('lualine.components.filename'):extend()
local highlight = require 'lualine.highlight'
local default_status_colors = { saved = { link = "Normal" }, modified = '#C70039' }

function custom_fname:init(options)
  custom_fname.super.init(self, options)
  self.status_colors = {
    saved = highlight.create_component_highlight_group(
      { bg = default_status_colors.saved }, 'filename_status_saved', self.options),
    modified = highlight.create_component_highlight_group(
      { bg = default_status_colors.modified }, 'filename_status_modified', self.options),
  }
  if self.options.color == nil then self.options.color = '' end
end

function custom_fname:update_status()
  local data = custom_fname.super.update_status(self)
  data = highlight.component_format_highlight(vim.bo.modified
      and self.status_colors.modified
      or self.status_colors.saved) .. data
  return data
end

return {
  custom_filename = custom_fname,
}
