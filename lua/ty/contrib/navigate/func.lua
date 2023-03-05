local M = {}

--- wrap function for navigate lsp diagnostics, used by keymaps.
--- @param next boolean "next" or "prev"
--- @param severity string "ERROR", "WARN", "INFO", "HINT"
function M.diagnostic_goto(next, severity)
  local go = next and vim.diagnostic.goto_next or vim.diagnostic.goto_prev
  local sev = severity and vim.diagnostic.severity[severity] or nil
  return function() go({ severity = sev }) end
end

function M.goto_definition_in_file(command) require('gtd').exec({ command = command or 'edit' }) end

function M.goto_code_references() Ty.NOTIFY('refer') end

function M.jump_to_tag(target)
  local method_name = ({
    parent = 'jumpParent',
    next = 'jumpNextSibling',
    prev = 'jumpPrevSibling',
    child = 'jumpChild',
  })[target]
  require('jump-tag')[method_name]()
end

return M
