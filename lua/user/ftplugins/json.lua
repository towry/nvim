local M = {}

-- Function to toggle the line for a given package name and version in a package.json file
local function togglePackageWorkspaceModifier()
  -- Get the current line
  local currentLine = vim.fn.getline('.')

  -- Extract the package name and version from the current line
  local packageName, version = string.match(currentLine, '"([^"]+)": "([^"]+)"')

  -- Check if the package name and version are found
  if packageName and version then
    -- Construct the search patterns
    local pattern1 = string.format('workspace:%s', version)
    local pattern2 = string.format('%s', version)

    -- Check if the line contains the first pattern
    if string.find(currentLine, pattern1) then
      -- Replace the line with the modified version using the second pattern
      vim.fn.setline('.', string.gsub(currentLine, pattern1, pattern2))
      -- Check if the line contains the second pattern
    elseif string.find(currentLine, pattern2) then
      -- Replace the line with the modified version using the first pattern
      vim.fn.setline('.', string.gsub(currentLine, pattern2, pattern1))
    end
    vim.print(pattern2, pattern1, currentLine)
  end
end

function M.attach_packagejson()
  local set = require('userlib.runtime.keymap').map_buf_thunk(0)
  set('n', '<localleader>tw', togglePackageWorkspaceModifier, {
    desc = 'Toggle dep version workspace',
  })
end

function M.attach()
  local bufname = vim.api.nvim_buf_get_name(0)
  -- is match package.json
  if bufname:match('package.json') then
    M.attach_packagejson()
  end
end

return M
