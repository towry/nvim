---@return boolean
local function toggleterm_kill_all()
    local terms = require('toggleterm.terminal').get_all()
    local is_shut = false
    local job_ids = {}

    for _, term in ipairs(terms) do
        table.insert(job_ids, term.job_id)
        vim.fn.jobstop(term.job_id)
        is_shut = true
    end

    if #job_ids > 0 then vim.fn.jobwait(job_ids, 2000) end
    return is_shut
end


return toggleterm_kill_all
