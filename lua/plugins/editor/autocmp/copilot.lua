return {
  {
    -- https://github.com/dermoumi/dotfiles/blob/418de1a521e4f4ac6dc0aa10e75ffb890b0cb908/nvim/lua/plugins/copilot.lua#L4
    'github/copilot.vim',
    event = { 'InsertEnter' },
    keys = {
      { '<C-/>', mode = 'i' },
      {
        '<leader>zp',
        '<cmd>Copilot panel<cr>',
        desc = 'Open Copilot panel'
      }
    },
    cmd = { 'Copilot' },
    config = function()
      -- <C-/>
      vim.keymap.set({ 'i' }, '<C-/>', 'copilot#Suggest()', {
        silent = true,
        expr = true,
        script = true,
      })
    end,
    init = function()
      vim.g.copilot_filetypes = {
        ['*'] = true,
        ['TelescopePrompt'] = false,
        ['TelescopeResults'] = false,
      }
      vim.g.copilot_no_tab_map = true
      vim.g.copilot_tab_fallback = ''
      vim.g.copilot_assume_mapped = true
      vim.g.copilot_proxy = '127.0.0.1:1080'
      vim.g.copilot_proxy_strict_ssl = false
      vim.api.nvim_create_autocmd({ 'FileType' }, {
        pattern = 'copilot.*',
        callback = function(ctx)
          vim.keymap.set('n', 'q', '<cmd>close<cr>', {
            silent = true,
            buffer = ctx.buf,
            noremap = true,
          })
        end,
      })
    end
  }
}
