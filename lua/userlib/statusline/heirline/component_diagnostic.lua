local DiagnosticIcons = require('userlib.lsp.cfg.diagnostic').DiagnosticIcons

return {
  static = DiagnosticIcons,

  init = function(self)
    self.errors =
        #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
    self.warnings =
        #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
    self.hints =
        #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
    self.info =
        #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
    self.total = self.errors + self.warnings + self.hints + self.info
  end,

  update = { "DiagnosticChanged", "BufEnter" },

  {
    condition = function(self)
      return self.errors > 0
    end,
    provider = function(self)
      return "" .. (self.error_icon or '') .. self.errors
    end,
    hl = "DiagnosticError",
  },
  {
    condition = function(self)
      return self.warnings > 0
    end,
    provider = function(self)
      return "" .. (self.warn_icon or '') .. self.warnings
    end,
    hl = "DiagnosticWarn",
  },
  {
    condition = function(self)
      return self.info > 0
    end,
    provider = function(self)
      return "" .. (self.info_icon or '') .. self.info
    end,
    hl = "DiagnosticInfo",
  },
  {
    condition = function(self)
      return self.hints > 0
    end,
    provider = function(self)
      return "" .. (self.hint_icon or '') .. self.hints
    end,
    hl = "DiagnosticHint",
  },
  -- {
  --   provider = function(self)
  --     return self.total == 0 and " " or ""
  --   end,
  --   hl = "DiagnosticInfo",
  -- },
}
