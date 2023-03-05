--- configurations for searching, replace, finding files, search folders, project files tree etc.
local M = {}

-- @see telescope.builtin.find_files
-- @type table
M.find_files = {
  -- @see telescope.builtin.find_files.hidden
  -- @type boolean
  hidden = true,
  -- wether use last search prompt.
  -- @type boolean
  use_last_prompt = true,
  ignore_pattern = {
    '^.vim/',
    '^.local/',
    '^.cache/',
    '^Downloads/',
    '^.git/',
    '^Dropbox/',
    '^Library/',
    '^undodir/',
    '^plugged/',
    '^sessions/',
    '^node_modules/',
    '^bower_components/',
    '^dist/',
    '^public/',
    'lazy-lock.json',
  },
}

return M
