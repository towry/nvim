local M = {}

function M.setup()
  vim.api.nvim_create_autocmd({ 'UIEnter' }, {
    once = true,
    callback = function()
      local is_ok, Spinner = pcall(require, 'ty.contrib.ui.spinner')
      if not is_ok then
        Ty.NOTIFY('spinner dep missing')
        return
      end
      local spinners = {}

      local function format_msg(msg, percentage)
        msg = msg or ''
        if not percentage then return msg end
        return string.format('%2d%%\t%s', percentage, msg)
      end

      vim.api.nvim_create_autocmd({ 'User' }, {
        pattern = { 'LspProgressUpdate' },
        group = vim.api.nvim_create_augroup('LSPNotify', { clear = true }),
        desc = 'LSP progress notifications',
        callback = function()
          for _, c in ipairs(vim.lsp.get_active_clients()) do
            for token, ctx in pairs(c.messages.progress) do
              if not spinners[c.id] then spinners[c.id] = {} end
              local s = spinners[c.id][token]
              if not ctx.done then
                if not s then
                  spinners[c.id][token] = Spinner(format_msg(ctx.message, ctx.percentage), vim.log.levels.INFO, {
                    title = ctx.title and string.format('%s: %s', c.name, ctx.title) or c.name,
                  })
                else
                  s:update(format_msg(ctx.message, ctx.percentage))
                end
              else
                c.messages.progress[token] = nil
                if s then
                  s:done(ctx.message or 'Complete', nil, {
                    icon = '',
                  })
                  spinners[c.id][token] = nil
                end
              end
            end
          end
        end,
      })
    end,
  })
end

return M
