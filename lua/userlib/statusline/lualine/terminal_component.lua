local TermsComponent = require('lualine.component'):extend()
local terms_count = require('userlib.terminal').terms_count

local default_options = {
  symbols = {
    term = ' ',
  }
}

function TermsComponent.init(self, options)
  options = options or {}
  options.on_click = function() vim.cmd([[Telescope termfinder find]]) end

  TermsComponent.super.init(self, options)
  self.options = vim.tbl_deep_extend('keep', options or {}, default_options)
  self.tick = 0
  self.count = 0
end

function TermsComponent.update_status(self)
  if self.tick <= 0 then
    self.count = terms_count()
  end
  self.tick = self.tick + 1
  if self.tick >= 20 then
    self.tick = 0
  end

  if self.count <= 0 then
    return self.options.symbols.term
  end

  return string.format('%s%d', self.options.symbols.term, self.count)
end

return TermsComponent
