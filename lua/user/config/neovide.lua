do
  if not vim.g.neovide then
    return
  end
end

-- vim.o.guifont = 'Iosevka Term:h15'
vim.g.neovide_window_blurred = true
vim.g.neovide_floating_blur_amount_x = 5.0
vim.g.neovide_floating_blur_amount_y = 5.0
vim.g.neovide_floating_shadow = true
vim.g.neovide_floating_z_height = 10
vim.g.neovide_light_angle_degrees = 45
vim.g.neovide_light_radius = 5
vim.g.neovide_show_border = true
vim.g.neovide_theme = 'auto'
vim.g.neovide_unlink_border_highlights = true
-- vim.g.neovide_refresh_rate = 60
vim.g.neovide_confirm_quit = true
vim.g.neovide_input_macos_alt_is_meta = true
vim.g.neovide_input_ime = false
vim.g.neovide_cursor_animation_length = 0.05
vim.g.neovide_cursor_trail_size = 0.8
vim.g.neovide_cursor_antialiasing = true
vim.g.neovide_cursor_animate_in_insert_mode = false
vim.g.neovide_cursor_animate_command_line = false
vim.g.neovide_cursor_unfocused_outline_width = 0.125
vim.g.neovide_cursor_smooth_blink = false
vim.g.neovide_underline_stroke_scale = 0.1

vim.keymap.set('v', '<D-c>', '"+y') -- Copy
vim.keymap.set('n', '<D-v>', '"+P') -- Paste normal mode
vim.keymap.set('v', '<D-v>', '"+P') -- Paste visual mode
vim.keymap.set('c', '<D-v>', '<C-R>+') -- Paste command mode
vim.keymap.set('i', '<D-v>', '<ESC>l"+Pli') -- Paste insert mode

local function set_ime(args)
  if args.event:match('Enter$') then
    vim.g.neovide_input_ime = true
  else
    vim.g.neovide_input_ime = false
  end
end

local ime_input = vim.api.nvim_create_augroup('ime_input', { clear = true })

vim.api.nvim_create_autocmd({ 'InsertEnter', 'InsertLeave' }, {
  group = ime_input,
  pattern = '*',
  callback = set_ime,
})

vim.api.nvim_create_autocmd({ 'CmdlineEnter', 'CmdlineLeave' }, {
  group = ime_input,
  pattern = '[/\\?]',
  callback = set_ime,
})
