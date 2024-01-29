local DiagnosticIcons = require('userlib.lsp.cfg.diagnostic').DiagnosticIcons

return {
  static = DiagnosticIcons,

  init = function(self)
    if vim.diagnostic.count then
      local count = vim.diagnostic.count(0)
      self.errors = count[vim.diagnostic.severity.ERROR] or 0
      self.warnings = count[vim.diagnostic.severity.WARN] or 0
      self.hints = count[vim.diagnostic.severity.HINT] or 0
      self.info = count[vim.diagnostic.severity.INFO] or 0
    else
      self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
      self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
      self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
      self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    end
    self.total = self.errors + self.warnings + self.hints + self.info
  end,

  update = { 'DiagnosticChanged', 'BufEnter' },
  {

    condition = function(self)
      if self.total <= 0 then
        return false
      end
      return true
    end,

    {
      -- left pad
      provider = ' ',
    },

    {
      condition = function(self)
        return self.errors > 0
      end,
      provider = function(self)
        return '' .. (self.error_icon or '') .. self.errors
      end,
      hl = 'DiagnosticError',
    },
    {
      condition = function(self)
        return self.warnings > 0
      end,
      provider = function(self)
        return '' .. (self.warn_icon or '') .. self.warnings
      end,
      hl = 'DiagnosticWarn',
    },
    {
      condition = function(self)
        return self.info > 0
      end,
      provider = function(self)
        return '' .. (self.info_icon or '') .. self.info
      end,
      hl = 'DiagnosticInfo',
    },
    {
      condition = function(self)
        return self.hints > 0
      end,
      provider = function(self)
        return '' .. (self.hint_icon or '') .. self.hints
      end,
      hl = 'DiagnosticHint',
    },
  },
}
