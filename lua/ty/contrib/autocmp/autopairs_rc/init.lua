local M = {}

function M.setup()
  local config = require('ty.core.config').autocmp
  local npairs = require('nvim-autopairs')
  local cmp_autopairs = require('nvim-autopairs.completion.cmp')
  local cmpcore = require('cmp')

  local args = config:merge('autocomplete.autopairs.config', {
    disable_filetype = {
      'TelescopePrompt',
    },
    disable_in_macro = true,
    disable_in_replace_mode = true,
    enable_check_bracket_line = true,
    check_ts = true,
    ts_config = {
      lua = { 'string' },
      javascript = { 'template_string' },
      java = false,
    },
  })
  npairs.setup(args)

  local Kind = cmpcore.lsp.CompletionItemKind
  local handlers = require('nvim-autopairs.completion.handlers')
  -- local utils = require('nvim-autopairs.utils')
  local default_handler = function(char, item, bufnr, commit_character)
    -- local line = utils.text_get_current_line(bufnr)
    -- local _, col = utils.get_cursor()
    -- local char_before, char_after = utils.text_cusor_line(line, col, 1, 1, false)

    -- do not add pairs if commit characters exists, like `.`, or `,`.
    if commit_character ~= nil then return end
    -- do not add pairs if in jsx.
    local ts_current_line_node_type = Ty.TS_GET_NODE_TYPE()
    if
      vim.tbl_contains({ 'jsx_self_closing_element', 'jsx_opening_element' }, ts_current_line_node_type)
      and (item.kind == Kind.Function or item.kind == Kind.Method)
    then
      return
    end

    handlers['*'](char, item, bufnr, commit_character)
  end

  cmpcore.event:on(
    'confirm_done',
    cmp_autopairs.on_confirm_done({
      filetypes = {
        ['*'] = {
          ['('] = {
            handler = default_handler,
          },
        },
        -- disable for tex
        tex = false,
      },
    })
  )

  --- setup rules.
  local allowed_rules = config:get('autocomplete.autopairs_rules', {})
  local rules = require('ty.contrib.autocmp.autopairs_rc.rules')
  for _, rule in ipairs(allowed_rules) do
    -- if rule exist in module and is a function, call it.
    if rules[rule] and type(rules[rule]) == 'function' then rules[rule]() end
  end
end

return M
