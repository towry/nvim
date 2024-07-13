---@param bufnr number
---@param winid number
local function nvim_smart_close(bufnr, winid)
    bufnr = bufnr or 0
    winid = winid or 0

    if vim.wo[winid].previewwindow then
        vim.cmd.pclose()
        return
    elseif vim.api.nvim_win_get_config(0).relative ~= "" then
        vim.cmd.fclose()
        return
    elseif vim.bo[bufnr].buftype ~= "" then
        vim.cmd("silent! bd")
        return
    else
        vim.cmd("silent! hide")
    end
end

return nvim_smart_close
