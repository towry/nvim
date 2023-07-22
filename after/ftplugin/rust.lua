local set = function (...)
  vim.api.nvim_buf_set_keymap(0, ...)
end

set('n', '<localleader>cr', ':!cargo run<CR>', {noremap = true})
