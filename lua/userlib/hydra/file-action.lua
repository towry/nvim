local M = {}

local _ = function(callback)
  return function()
    vim.cmd('wincmd w')
    vim.schedule(callback)
  end
end


M.open = function(file_path, buffer)
  local ok, Hydra = pcall(require, 'hydra')
  if not ok then return end

  local hydra = Hydra({
    name = '',
    mode = { 'n', 'i' },
    config = {
      buffer = buffer,
    },
    heads = {
      { "y", _(function()
        vim.fn.setreg('+', file_path)
      end), { private = true, desc = "Copy", exit = true } },
    }
  })

  hydra:activate()
end

return M
