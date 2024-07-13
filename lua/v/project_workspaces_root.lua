local _cwd = vim.uv.cwd()
local function nvim_workspaces_root_()
    --- NOTE: need better implementation.
    return _cwd
end

return nvim_workspaces_root_
