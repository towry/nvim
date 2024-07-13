local function nvim_has_keymap(key, mode) return vim.fn.hasmapto(key, mode) == 1 end
return nvim_has_keymap
