local plug = require('userlib.runtime.pack').plug

local function setup_coc_lsp_keys()
  local keymap = require('userlib.runtime.keymap')
  local set, cmd, cmd_modcall = keymap.set, keymap.cmdstr, keymap.cmd_modcall
  local opts = { silent = true, nowait = true }

  --- diagnostic nav
  set('n', ']dd', '<Plug>(coc-diagnostic-next)', opts)
  set('n', '[dd', '<Plug>(coc-diagnostic-prev)', opts)

  --- code nav
  set('n', 'gd', '<Plug>(coc-definition)', opts)
  set('n', 'gy', '<Plug>(coc-type-definition)', opts)
  set('n', '<localleader>gi', '<Plug>(coc-implementation)', opts)
  set('n', '<localleader>gr', '<Plug>(coc-references)', opts)
  -- Symbol renaming
  set('n', '<leader>crn', '<Plug>(coc-rename)', opts)
  -- Formatting selected code
  set('x', '<leader>cf', '<Plug>(coc-format-selected)', opts)
  set('n', '<leader>cf', '<Plug>(coc-format-selected)', opts)
  set('x', '<leader>ca', '<Plug>(coc-codeaction-selected)', opts)
  set('n', '<leader>ca', '<Plug>(coc-codeaction-selected)', opts)
  -- organize imports
  set('n', '<leader>ci', [[:<C-u>call CocActionAsync('runCommand', 'editor.action.organizeImport')<cr>]], opts)
  set('n', '<leader>cld', [[:<C-u>CocList diagnostics<cr>]], opts)
  --- manage extensions
  set('n', '<leader>clE', ':<C-u>CocList extensions<cr>', opts)
  -- Show commands
  set('n', '<space>clc', ':<C-u>CocList commands<cr>', opts)

  -- Remap keys for apply code actions at the cursor position.
  set('n', '<leader>cc', '<Plug>(coc-codeaction-cursor)', opts)
  -- Remap keys for apply source code actions for current file.
  set('n', '<leader>cA', '<Plug>(coc-codeaction-source)', opts)
  set('x', '<leader>cA', '<Plug>(coc-codeaction-source)', opts)
  -- Apply the most preferred quickfix action on the current line.
  set('n', '<leader>cqf', '<Plug>(coc-fix-current)', opts)
  set('n', '<leader>crf', '<Plug>(coc-codeaction-refactor)', { silent = true })
  set('x', '<leader>crF', '<Plug>(coc-codeaction-refactor-selected)', { silent = true })
  set('n', '<leader>crF', '<Plug>(coc-codeaction-refactor-selected)', { silent = true })
  -- Run the Code Lens actions on the current line
  set('n', '<leader>ccl', '<Plug>(coc-codelens-action)', opts)

  -- Remap <C-f> and <C-b> to scroll float windows/popups
  ---@diagnostic disable-next-line: redefined-local
  local opts = { silent = true, nowait = true, expr = true }
  set('n', '<C-f>', 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
  set('n', '<C-d>', 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-d>"', opts)
  set('i', '<C-f>', 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(1)<cr>" : "<Right>"', opts)
  set('i', '<C-d>', 'coc#float#has_scroll() ? "<c-r>=coc#float#scroll(0)<cr>" : "<Left>"', opts)
  set('v', '<C-f>', 'coc#float#has_scroll() ? coc#float#scroll(1) : "<C-f>"', opts)
  set('v', '<C-d>', 'coc#float#has_scroll() ? coc#float#scroll(0) : "<C-d>"', opts)

  local function show_docs()
    local cw = vim.fn.expand('<cword>')
    if vim.fn.index({ 'vim', 'help' }, vim.bo.filetype) >= 0 then
      vim.api.nvim_command('h ' .. cw)
    elseif vim.api.nvim_eval('coc#rpc#ready()') then
      vim.fn.CocActionAsync('doHover')
    else
      vim.api.nvim_command('!' .. vim.o.keywordprg .. ' ' .. cw)
    end
  end
  set('n', 'KK', show_docs, opts)
end

local function setup_coc_autocmd()
  -- Highlight the symbol and its references on a CursorHold event(cursor is idle)
  vim.api.nvim_create_augroup('CocGroup', { clear = true })
  vim.api.nvim_create_autocmd('CursorHold', {
    group = 'CocGroup',
    command = "silent call CocActionAsync('highlight')",
    desc = 'Highlight symbol under cursor on CursorHold',
  })
  -- Update signature help on jump placeholder
  vim.api.nvim_create_autocmd('User', {
    group = 'CocGroup',
    pattern = 'CocJumpPlaceholder',
    command = "call CocActionAsync('showSignatureHelp')",
    desc = 'Update signature help on jump placeholder',
  })
end

return plug({
  'neoclide/coc.nvim',
  branch = 'release',
  cmd = {
    'CocInstall',
  },
  config = false,
  init = function()
    local keymap = require('userlib.runtime.keymap')
    local set, cmd, cmd_modcall = keymap.set, keymap.cmdstr, keymap.cmd_modcall
    local opts = {
      silent = true,
      noremap = true,
      expr = true,
      replace_keycodes = false,
    }
    local fn = vim.fn
    local check_backspace = function()
      local col = vim.fn.col('.') - 1
      return col == 0 or vim.fn.getline('.'):sub(col, col):match('%s') ~= nil
    end

    set('i', '<Tab>', function()
      if fn['coc#pum#visible']() == 1 then
        return fn['coc#pum#next'](1)
      elseif check_backspace() then
        return '<Plug>(neotab-out)'
      else
        return fn['coc#refresh']()
      end
    end, opts)
    set('i', '<S-Tab>', function()
      if vim.fn['coc#pum#visible']() == 1 then
        return vim.fn['coc#pum#prev'](1)
      end
      return '<C-h>'
    end, opts)
    set('i', '<CR>', function()
      if vim.fn['coc#pum#visible']() == 1 then
        return vim.fn['coc#pum#confirm']()
      end
      return '<CR>'
    end, opts)
    --- trigger coc autocmp
    set('i', '<C-y>', 'coc#refresh()', opts)
    set('i', '<C-j>', '<Plug>(coc-snippets-expand-jump)', opts)

    setup_coc_lsp_keys()
    setup_coc_autocmd()
  end,
})
