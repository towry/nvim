local function init_icons(self)
  local has = #vim.fn.sign_getdefined("DiagnosticSignError") > 0
  if not has then return {} end
  self.error_icon = vim.fn.sign_getdefined("DiagnosticSignError")[1].text
  self.warn_icon = vim.fn.sign_getdefined("DiagnosticSignWarn")[1].text
  self.info_icon = vim.fn.sign_getdefined("DiagnosticSignInfo")[1].text
  self.hint_icon = vim.fn.sign_getdefined("DiagnosticSignHint")[1].text

  return {
    error_icon = self.error_icon or '',
    warn_icon = self.warn_icon or '',
    info_icon = self.info_icon or '',
    hint_icon = self.hint_icon or '',
  }
end

return {
  static = init_icons({}),

  init = function(self)
    if not self.error_icon or not self.warn_icon or not self.info_icon or not self.hint_icon then
      init_icons(self)
    end
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
      return " " .. (self.error_icon or '') .. self.errors
    end,
    hl = "DiagnosticError",
  },
  {
    condition = function(self)
      return self.warnings > 0
    end,
    provider = function(self)
      return " " .. (self.warn_icon or '') .. self.warnings
    end,
    hl = "DiagnosticWarn",
  },
  {
    condition = function(self)
      return self.info > 0
    end,
    provider = function(self)
      return " " .. (self.info_icon or '') .. self.info
    end,
    hl = "DiagnosticInfo",
  },
  {
    condition = function(self)
      return self.hints > 0
    end,
    provider = function(self)
      return " " .. (self.hint_icon or '') .. self.hints
    end,
    hl = "DiagnosticHint",
  },
  -- {
  --   provider = function(self)
  --     return self.total == 0 and " " or " "
  --   end,
  --   hl = "dkoStatusGood",
  -- },
}
