local au = require('userlib.runtime.au')
local plug = require('userlib.runtime.pack').plug

---{{{ functions
local function setup_coc_commands()
  require('userlib.legendary').register('coc', function(lg)
    lg.commands({
      {
        ':CocCommand workspace.inspectEdit',
        description = 'Coc workspace inspect edit',
      },
      {
        ':CocConfig',
        description = 'Open coc config',
      },
    })
  end)
end

local function setup_coc_lsp_keys()
  local keymap = require('userlib.runtime.keymap')
  local set = keymap.set
  local _ = function(desc)
    return { silent = true, nowait = true, expr = false, noremap = true, desc = '[Coc] ' .. desc }
  end

  --- diagnostic nav
  set('n', ']dd', "m'<Plug>(coc-diagnostic-next)", _('diagnostic next'))
  set('n', '[dd', "m'<Plug>(coc-diagnostic-prev)", _('diagnostic prev'))
  set('n', ']de', "m'<Plug>(coc-diagnostic-next-error)", _('diagnostic error next'))
  set('n', '[de', "m'<Plug>(coc-diagnostic-prev-error)", _('diagnostic error prev'))

  --- code navigation
  set('n', 'gd', ':<C-u>keepjumps call CocActionAsync("jumpDefinition")<cr>', _('Go to definition'))
  set(
    'n',
    '<C-w>d',
    ':<C-u>keepjumps call CocActionAsync("jumpDefinition", "vsplit")<cr>',
    _('Go to definition in vsplit')
  )
  set('n', 'gy', ':<C-u>keepjumps call CocActionAsync("jumpTypeDefinition")<cr>', _(''))
  set('n', '<leader>cd', '<Plug>(coc-implementation)', _('Go to implementation'))
  set('n', 'gr', '<Plug>(coc-references)', _('Show references'))
  -- Symbol renaming
  set('n', '<leader>crn', '<Plug>(coc-rename)', _('Rename symbol'))
  -- Formatting selected code
  set(
    { 'x', 'v' },
    '<leader>cf',
    [[:<C-u>'<,'>call CocActionAsync('formatSelected', visualmode())<cr>]],
    _('Format selected code')
  )
  set('n', '<leader>cf', function()
    if vim.wo.diff then
      vim.notify('Format entire file in diff mode is danger, please format selected region only')
      return
    end

    return [[:<C-u>call CocActionAsync('format')<cr>]]
  end, { desc = 'Format entire file', expr = true, silent = true, nowait = true, noremap = true })
  set('x', '<leader>ca', '<Plug>(coc-codeaction-selected)', _('Code action on selected'))
  set('n', '<leader>ca', '<Plug>(coc-codeaction-line)', _('Code action for line'))
  -- Organize imports
  set(
    'n',
    '<leader>co',
    [[:<C-u>call CocActionAsync('runCommand', 'editor.action.organizeImport')<cr>]],
    _('Organize imports')
  )
  set('n', '<leader>cld', [[:<C-u>CocList diagnostics<cr>]], _('List diagnostics'))
  --- Manage extensions
  set('n', '<leader>clE', ':<C-u>CocList extensions<cr>', _('List extensions'))
  -- Show commands
  set('n', '<space>cc', ':<C-u>CocList commands<cr>', _('List commands'))

  -- Remap keys for apply code actions at the cursor position
  set('n', '<leader>c_', '<Plug>(coc-codeaction-cursor)', _('Apply code action at cursor'))
  -- Remap keys for apply source code actions for current file
  set('n', '<leader>cA', '<Plug>(coc-codeaction-source)', _('Apply source code actions'))
  set('x', '<leader>cA', '<Plug>(coc-codeaction-source)', _('Apply source code actions (visual)'))
  -- Apply the most preferred quickfix action on the current line
  set('n', '<leader>cqf', '<Plug>(coc-fix-current)', _('Apply quickfix action on current line'))
  set('n', '<leader>crf', '<Plug>(coc-codeaction-refactor)', { silent = true, desc = '[Coc] Refactor code' })
  set(
    'x',
    '<leader>crF',
    '<Plug>(coc-codeaction-refactor-selected)',
    { silent = true, desc = '[Coc] Refactor selected code', expr = false }
  )
  set(
    'n',
    '<leader>crF',
    '<Plug>(coc-codeaction-refactor-selected)',
    { silent = true, desc = '[Coc] Refactor selected code', expr = false }
  )
  -- Run the Code Lens actions on the current line
  set('n', '<leader>cC', '<Plug>(coc-codelens-action)', _('Codelens action'))

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
  set('n', 'KK', show_docs, { silent = true, expr = false, nowait = true })
end

local function setup_coc_autocmd()
  -- Highlight the symbol and its references on a CursorHold event(cursor is idle)
  vim.api.nvim_create_augroup('CocGroup', { clear = true })
  vim.api.nvim_create_autocmd('CursorHold', {
    group = 'CocGroup',
    command = "silent call CocActionAsync('highlight')",
    desc = 'Highlight symbol under cursor on CursorHold',
  })

  vim.api.nvim_create_autocmd('User', {
    group = 'CocGroup',
    pattern = { 'CocDiagnosticChange', 'CocStatusChange' },
    command = 'redrawstatus',
  })
  -- Update signature help on jump placeholder
  vim.api.nvim_create_autocmd('User', {
    group = 'CocGroup',
    pattern = 'CocJumpPlaceholder',
    command = "call CocActionAsync('showSignatureHelp')",
    desc = 'Update signature help on jump placeholder',
  })
  vim.api.nvim_create_autocmd('BufWritePre', {
    group = 'CocGroup',
    pattern = '*',
    callback = function(ctx)
      local bufnr = ctx.buf
      if vim.b[bufnr].coc_enabled == 0 or vim.bo[bufnr].buftype ~= '' then
        return
      end
      if vim.cfg.runtime__starts_as_gittool or vim.wo.diff then
        return
      end
      if (bufnr or bufnr == 0) and vim.b[bufnr].autoformat_disable then
        return
      end

      if not vim.fn.CocHasProvider('format') then
        return
      end

      vim.cmd([[call CocAction("format") | sleep 1m]])
    end,
  })
  vim.api.nvim_create_autocmd({ 'WinEnter', 'BufEnter' }, {
    group = 'CocGroup',
    callback = function()
      --- https://github.com/neoclide/coc.nvim/issues/3012
      if vim.cfg.ui__window_equalalways == true then
        return
      end

      -- if vim.bo.buftype == 'nofile' then
      --   vim.cmd('set equalalways')
      -- else
      --   vim.cmd('set noequalalways')
      -- end
    end,
  })
end
---}}}

return plug({
  -- 'neoclide/coc.nvim',
  -- branch = 'release',
  'pze/coc.nvim',
  dev = false,
  branch = 'master',
  build = 'npm ci',
  cmd = {
    'CocInstall',
  },
  enabled = vim.cfg.edit__use_coc and not vim.g.vscode,
  event = 'User FileOpenedAfter',
  ---{{{config
  config = function()
    local keymap = require('userlib.runtime.keymap')
    local set = keymap.set
    local opts = {
      silent = true,
      noremap = true,
      expr = true,
      replace_keycodes = true,
    }
    local fn = vim.fn

    set('i', '<Tab>', function()
      if fn['coc#pum#visible']() == 1 then
        return fn['coc#pum#next'](1)
      elseif fn['coc#expandableOrJumpable']() then
        return [[<Plug>(coc-snippets-expand-jump)]]
      elseif Ty.ModFnCall('neogen', 'jumpable') then
        Ty.ModFnCall('neogen', 'jump_next')
      else
        return package.loaded['neotab'] and '<Plug>(neotab-out)' or '<Tab>'
      end
    end, opts)
    set('i', '<S-Tab>', function()
      if vim.fn['coc#pum#visible']() == 1 then
        return vim.fn['coc#pum#prev'](1)
      elseif Ty.ModFnCall('neogen', 'jumpable', true) then
        Ty.ModFnCall('neogen', 'jump_prev')
      end
      return '<C-h>'
    end, opts)
    set('i', '<CR>', function()
      if vim.fn['coc#pum#visible']() == 1 and vim.fn['coc#pum#info']()['index'] ~= -1 then
        return vim.fn['coc#pum#confirm']()
      end
      return '<CR>'
    end, opts)

    --- trigger coc autocmp and ai
    set('i', '<C-x><C-x>', function()
      vim.fn['coc#refresh']()
    end, opts)

    --- prevent some other plugin like rsi.vim override this mapping.
    au.define_autocmd({ 'InsertEnter' }, {
      --- must different group
      group = 'CocGroupLazy',
      once = true,
      callback = vim.schedule_wrap(function()
        set('i', '<C-j>', function()
          if Ty.has_ai_suggestions() and Ty.has_ai_suggestion_text() then
            if vim.fn['coc#pum#visible']() == 1 then
              vim.fn['coc#pum#cancel']()
            end
            if vim.b._copilot then
              vim.fn.feedkeys(vim.fn['copilot#Accept'](), 'i')
            elseif vim.b._codeium_completions then
              vim.fn.feedkeys(vim.fn['codeium#Accept'](), 'i')
            end
          else
            return vim.api.nvim_replace_termcodes('<Plug>(coc-snippets-expand-jump', true, true, false)
          end
        end, {
          noremap = false,
          remap = true,
          expr = false,
        })
      end),
    })

    setup_coc_lsp_keys()
    setup_coc_autocmd()
    setup_coc_commands()

    ----------------------------------------------------------------------------
    -- {{{some config
    -- https://github.com/neoclide/coc.nvim/wiki/Using-coc-extensions#implemented-coc-extensions
    vim.g.coc_global_extensions = {
      'coc-json',
      'coc-css',
      'coc-tsserver',
      'coc-html',
      'coc-highlight',
      'coc-html-css-support',
      -- 'coc-lua',
      'coc-sumneko-lua',
      'coc-eslint',
      'coc-prettier',
      --- rust
      --- `rustup component add rust-analyzer`
      'coc-rust-analyzer',
      'coc-toml',
      --- for vue
      '@yaegassy/coc-volar',
      'coc-yaml',
      -- snippets
      'coc-snippets',
      '@statiolake/coc-stylua',
      'coc-sumneko-lua',
      --- Symbols outline
      --- tabnine
      -- 'coc-tabnine',
      'coc-tailwindcss',
      --- sources
      'coc-word', -- google 100000 english repo.
      'coc-omni', --- &omnifunc of current buffer.
    }
    vim.g.coc_disable_mappings_check = 1
    vim.g.coc_disable_uncaught_error = 1
    vim.g.coc_disable_transparent_cursor = 1
    vim.g.coc_notify_error_icon = ' '
    vim.g.coc_notify_warning_icon = ' '
    vim.g.coc_notify_info_icon = ' '
    vim.g.coc_status_error_sign = 'E'
    vim.g.coc_status_warning_sign = 'W'
    ---}}} end some config
  end, ---}}}
  ---{{{ init
  init = function()
    vim.env['NVIM_COC_LOG_LEVEL'] = 'error'
    vim.g.miniclues = vim.tbl_extend('error', vim.g.miniclues, {
      { mode = 'n', keys = '<leader>cl', desc = '+Coc lists' },
      { mode = 'n', keys = '<leader>cr', desc = '+Coc refactor' },
      { mode = 'n', keys = '<leader>cq', desc = '+Coc quickfix?' },
    })
  end,
  ---}}}
})

--- vim: fdl=0 fdm=marker fmr={{{,}}}
