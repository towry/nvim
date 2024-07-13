---Create an nvim command
---@param name string
---@param rhs string | fun(args: CommandArgs)
---@param opts table?
local function nvim_command(name, rhs, opts)
    opts = opts or {}
    vim.api.nvim_create_user_command(name, rhs, opts)
end

return nvim_command
