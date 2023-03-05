local M = {}

M.session = {
  -- Auto save last session.
  auto_save_last = true,
}

M.guess_indent = {
  ignore_filetypes = {},
  ignore_buftypes = {},
}

M.rooter = {
  patterns = { '.git', '_darcs', '.bzr', '.svn', '.vscode', '.gitmodules', 'pnpm-workspace.yaml' },
}

return M
