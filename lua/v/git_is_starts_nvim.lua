local V = require('v')

if not V.nvim_empty_argc or not V.git_in_mergetool then
    error("dependencies missing")
end

local git_start_nvim = function()
    if V.nvim_empty_argc() then return false end
    local argv = vim.v.argv
    local args = { { "-d" }, { "-c", "DiffConflicts" } }
    -- each table in args is pairs of args that may exists in argv to determin the
    -- return value is true or false.
    for _, arg in ipairs(args) do
        local is_match = true
        for _, v in ipairs(arg) do
            if not vim.tbl_contains(argv, v) then is_match = false end
        end
        if is_match then return true end
    end

    return V.git_in_mergetool()
end

return git_start_nvim
