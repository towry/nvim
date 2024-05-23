--- https://raw.githubusercontent.com/junnplus/lsp-setup.nvim/main/lua/lsp-setup/inlay_hints/init.lua
local M = {}

M.opts = {
  enabled = false,
  highlight = 'Comment',
  insert_only = false,
}
M.state = setmetatable({}, { __index = nil })

function M.setup(opts)
  M.opts = vim.tbl_deep_extend('keep', opts, M.opts)
  if not opts.enabled then
    return
  end

  if vim.lsp.inlay_hint == nil then
    vim.notify_once('LSP Inlayhints requires Neovim 0.10.0+ (ca5de93)', vim.log.levels.ERROR)
    return
  end

  vim.cmd.highlight('default link LspInlayHint ' .. M.opts.highlight)

  vim.api.nvim_create_augroup('LspSetup_Inlayhints', {})
  vim.api.nvim_create_autocmd('LspAttach', {
    group = 'LspSetup_Inlayhints',
    callback = function(args)
      if not (args.data and args.data.client_id) then
        return
      end

      local bufnr = args.buf
      local client = vim.lsp.get_client_by_id(args.data.client_id)
      M.on_attach(client, bufnr, opts)
    end,
  })
end

---@param opts {insert_only?:boolean}
function M.on_attach(client, bufnr, opts)
  if not client then
    vim.notify_once('LSP Inlayhints attached failed: nil client.', vim.log.levels.ERROR)
    return
  end
  if not client.server_capabilities.inlayHintProvider then
    return
  end

  if M.state[bufnr] then
    return
  end

  M.state[bufnr] = client.id

  if not opts.insert_only then
    vim.lsp.inlay_hint.enable(true, {
      bufnr = bufnr,
    })
  end
  if opts.insert_only then
    local gr = vim.api.nvim_create_augroup('_inlayhint_buf_' .. bufnr, { clear = true })
    vim.api.nvim_create_autocmd('InsertEnter', {
      group = gr,
      buffer = bufnr,
      callback = function()
        vim.lsp.inlay_hint.enable(true, {
          bufnr = bufnr,
        })
      end,
    })
    vim.api.nvim_create_autocmd('InsertLeave', {
      group = gr,
      buffer = bufnr,
      callback = function()
        vim.lsp.inlay_hint.enable(false, {
          bufnr = bufnr,
        })
      end,
    })
  end
end

return M
