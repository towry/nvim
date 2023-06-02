local M = {}

function M.setup()
  -- ╭──────────────────────────────────────────────────────────╮
  -- │ Keymappings                                              │
  -- ╰──────────────────────────────────────────────────────────╯

  -- Half-window movements:
  vim.keymap.set({ 'n', 'x', 'i' }, '<C-u>', "<Cmd>lua Ty.SCROLL('<C-u>')<CR>")
  vim.keymap.set({ 'n', 'x', 'i' }, '<C-d>', "<Cmd>lua Ty.SCROLL('<C-d>')<CR>")

  -- Page movements:
  vim.keymap.set('n', '<PageUp>', "<Cmd>lua Ty.SCROLL('<C-b>', 1, 1)<CR>")
  vim.keymap.set('n', '<PageDown>', "<Cmd>lua Ty.SCROLL('<C-f>', 1, 1)<CR>")

  -- Paragraph movements:
  vim.keymap.set({ 'n', 'x' }, '{', "<Cmd>lua Ty.SCROLL('{', 0)<CR>")
  vim.keymap.set({ 'n', 'x' }, '}', "<Cmd>lua Ty.SCROLL('}', 0)<CR>")

  -- Previous/next search result:
  -- vim.keymap.set('n', 'n', "<Cmd>lua Ty.SCROLL('n')<CR>", { remap = true, })
  -- vim.keymap.set('n', 'N', "<Cmd>lua Ty.SCROLL('N')<CR>", { remap = true, })
  -- vim.keymap.set('n', '*', "<Cmd>lua Ty.SCROLL('*')<CR>", { remap = true, })
  -- vim.keymap.set('n', '#', "<Cmd>lua Ty.SCROLL('#')<CR>", { remap = true, })
  -- vim.keymap.set('n', 'g*', "<Cmd>lua Ty.SCROLL('g*')<CR>", { remap = true, })
  -- vim.keymap.set('n', 'g#', "<Cmd>lua Ty.SCROLL('g#')<CR>", { remap = true, })

  -- Window scrolling:
  vim.keymap.set('n', 'zz', "<Cmd>lua Ty.SCROLL('zz', 0, 1)<CR>")
  vim.keymap.set('n', 'zt', "<Cmd>lua Ty.SCROLL('zt', 0, 1)<CR>")
  vim.keymap.set('n', 'zb', "<Cmd>lua Ty.SCROLL('zb', 0, 1)<CR>")
  vim.keymap.set('n', 'z.', "<Cmd>lua Ty.SCROLL('z.', 0, 1)<CR>")
  vim.keymap.set('n', 'z<CR>', "<Cmd>lua Ty.SCROLL('zt^', 0, 1)<CR>")
  vim.keymap.set('n', 'z-', "<Cmd>lua Ty.SCROLL('z-', 0, 1)<CR>")
  vim.keymap.set('n', 'z^', "<Cmd>lua Ty.SCROLL('z^', 0, 1)<CR>")
  vim.keymap.set('n', 'z+', "<Cmd>lua Ty.SCROLL('z+', 0, 1)<CR>")
end

return M
