local M = {}

local yanky_hydra = nil

M.open_yanky_ring_hydra = function(reg)
  local ok, Hydra = pcall(require, 'hydra')
  if not ok then return end

  if yanky_hydra == nil then
    yanky_hydra = Hydra({
      name = 'Yank ring',
      mode = 'n',
      heads = {
        { "<C-k>", ([[u!<esc>%s<Plug>(YankyPutBeforeLinewise)]]):format(reg and ('"' .. reg) or ''),
          {
            private = true,
            desc = "Put before line wise",
          } },
        { "<C-j>", ([[u!<esc>%s<Plug>(YankyPutAfterLinewise)]]):format(reg and ('"' .. reg) or ''),
          {
            private = true,
            desc = "Put before line wise",
          } },

        { "<C-n>", "<Plug>(YankyCycleForward)",  { private = true, desc = "↓" } },
        { "<C-p>", "<Plug>(YankyCycleBackward)", { private = true, desc = "↑" } },
      }
    })
  end

  yanky_hydra:activate()
end

return M
