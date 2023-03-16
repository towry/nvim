local M = {}

M.init = function()
  vim.api.nvim_create_autocmd("VimLeavePre", {
    pattern = "*",
    callback = function()
      local terms = require("toggleterm.terminal").get_all()
      local is_shut = false
      local job_ids = {}

      for _, term in ipairs(terms) do
        table.insert(job_ids, term.job_id)
        vim.fn.jobstop(term.job_id)
        is_shut = true
      end

      if #job_ids > 0 then
        vim.fn.jobwait(job_ids, 2000)
      end

      if is_shut then
        Ty.ECHO({ { "Shutting down all terminals", "WarningMsg" } }, false, {})
      end
    end,
  })
end

return M
