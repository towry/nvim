local projects_instance_map = {}

---@param cwd string
local function toggle_bacon_term(cwd)
  if vim.fn.executable('bacon') == 0 then
    vim.notify("bacon is not installed", vim.log.levels.ERROR)
    return
  end
  if not cwd or cwd == '' then
    return
  end

  if projects_instance_map[cwd] ~= nil then
    projects_instance_map[cwd]:close()
    projects_instance_map[cwd] = nil
    vim.notify("Bacon term is closed")
  else
    local cmd = ('bacon --job check-all')
    local term = require('toggleterm.terminal').Terminal:new({
      cmd = ([[echo "entering: %s" && echo "%s" && %s]]):format(cwd, cmd, cmd),
      dir = cwd,
      hidden = true,
      direction = 'vertical',
      close_on_exit = false,
      auto_scroll = true,
      float_opts = {
        border = 'curved',
        width = 0.9,
        height = 0.9,
      },
      on_open = function(term)
        vim.api.nvim_buf_set_keymap(term.bufnr, "n", "q", "<cmd>close<CR>", { noremap = true, silent = true })
      end,
      on_close = function()
        projects_instance_map[cwd] = nil
      end,
    })
    projects_instance_map[cwd] = term
    term:open()
  end
end

return {
  toggle_bacon_term = toggle_bacon_term
}
