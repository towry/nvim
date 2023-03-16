local M = {}

M.init = function()
  vim.api.nvim_create_autocmd("VimLeavePre", {
    pattern = "*",
    callback = function()
      local terms = require("toggleterm.terminal").get_all()
      local is_shut = false
      for _, term in ipairs(terms) do
        term:shutdown()
        is_shut = true
      end

      if is_shut then
        Ty.ECHO({ { "Shutting down all terminals", "WarningMsg" } }, false, {})
      end
    end,
  })
end

return M
