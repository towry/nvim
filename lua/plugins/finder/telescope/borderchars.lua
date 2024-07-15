local M = {}

M.dropdown_borderchars_default = {
  --- sharp corner borders
  { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
  prompt = { '─', '│', ' ', '│', '┌', '┐', '│', '│' },
  results = { '─', '│', '─', '│', '├', '┤', '┘', '└' },
  preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
}

M.dropdown_borderchars_prompt_bottom = {
  prompt = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
  results = { '─', '│', '─', '│', '╭', '╮', '┤', '├' },
  preview = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
}

return M
