local M = {}

M.dropdown_borderchars_default = {
  { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
  prompt = { "─", "│", " ", "│", '┌', '┐', "│", "│" },
  results = { "─", "│", "─", "│", "├", "┤", "┘", "└" },
  preview = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
}

M.dropdown_borderchars_prompt_bottom = {
  prompt = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
  results = { "─", "│", "─", "│", "╭", "╮", "┤", "├" },
  preview = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
}

return M
