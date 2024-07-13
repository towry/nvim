local git_in_mergetool = function()
    if vim.g.nvim_is_start_as_merge_tool == 1 then return true end
    local tail = vim.fn.expand("%:t")
    local args = { "MERGE_MSG", "COMMIT_EDITMSG" }
    if vim.tbl_contains(args, tail) then
        vim.g.nvim_is_start_as_merge_tool = 1
        return true
    end
    return false
end
return git_in_mergetool
