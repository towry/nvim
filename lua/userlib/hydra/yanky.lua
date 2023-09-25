local M = {}

local yanky_hydra = nil

M.open_yanky_ring_hydra = function(reg)
  local ok, Hydra = pcall(require, 'hydra')
  if not ok then return end

  if yanky_hydra == nil then
    yanky_hydra = Hydra({
      name = 'Yank ring',
      config = {
        on_exit = function() vim.cmd([[echo ' ']]) end,
      },
      mode = 'n',
      heads = {
        {
          '<C-k>',
          ([[u!<esc>%s<Plug>(YankyPutIndentBeforeLinewise)]]):format(reg and ('"' .. reg) or ''),
          {
            private = true,
            desc = 'Put before line wise',
            silent = true,
          },
        },
        {
          '<C-j>',
          ([[u!<esc>%s<Plug>(YankyPutIndentAfterLinewise)]]):format(reg and ('"' .. reg) or ''),
          {
            private = true,
            silent = true,
            desc = 'Put before line wise',
          },
        },

        { '<C-n>', '<Plug>(YankyCycleForward)', { private = true, desc = '↓' } },
        { '<C-p>', '<Plug>(YankyCycleBackward)', { private = true, desc = '↑' } },
        {
          '<C-f>',
          function()
            vim.schedule(function() require('telescope').extensions.yank_history.yank_history() end)
          end,
          {
            private = true,
            desc = 'History',
            -- must exit,
            exit = true,
          },
        },
      },
    })
  end

  yanky_hydra:activate()
end

return M
