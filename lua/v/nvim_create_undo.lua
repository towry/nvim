local CREATE_UNDO = vim.api.nvim_replace_termcodes("<c-G>u", true, true, true)
local function nvim_create_undo()
    if vim.api.nvim_get_mode().mode == "i" then vim.api.nvim_feedkeys(CREATE_UNDO, "n", false) end
end

return nvim_create_undo
