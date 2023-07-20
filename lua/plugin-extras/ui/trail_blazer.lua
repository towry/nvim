--- https://github.com/razak17/nvim/blob/32bb5b4df9fe5063b468324465afcf8c34b1db70/lua/user/plugins/motions.lua#L57
local plug = require('userlib.runtime.pack').plug
local fmt = string.format

local function get_available_stacks(notify)
  local available_stacks = require('trailblazer.trails').stacks.get_sorted_stack_names()
  if notify then
    vim.notify(fmt('Available stacks: %s', table.concat(available_stacks, ', ')), 'info', { title = 'TrailBlazer' })
  end
  return available_stacks
end

local function add_trail_mark_stack()
  vim.ui.input({ prompt = 'stack name: ' }, function(name)
    if not name then return end
    local available_stacks = get_available_stacks()
    if Ty.find_string(available_stacks, name) then
      vim.notify(fmt('"%s" stack already exists.', name), 'warn', { title = 'TrailBlazer' })
      return
    end
    local tb = require('trailblazer')
    tb.add_trail_mark_stack(name)
    vim.notify(fmt('"%s" stack created.', name), 'info', { title = 'TrailBlazer' })
  end)
end

local function delete_trail_mark_stack()
  vim.ui.input({ prompt = 'stack name: ' }, function(name)
    if not name then return end
    local available_stacks = get_available_stacks()
    if not Ty.find_string(available_stacks, name) then
      vim.notify(fmt('"%s" stack does not exist.', name), 'warn', { title = 'TrailBlazer' })
      return
    end
    local tb = require('trailblazer')
    tb.delete_trail_mark_stack(name)
    vim.notify(fmt('"%s" stack deleted.', name), 'info', { title = 'TrailBlazer' })
  end)
end

--- This enables you to quickly "bookmark" where you are right now,
--- naviagte to wherever you need to and come back by simply popping
--- the last mark off the stack using the "track back" feature. This is especially
--- useful when you need to quickly jump to a specific location in a different file or
--- window and return afterwards without the need for a permanent mark.
--- https://github.com/FelixKratz/dotfiles/blob/6a84fc7882c31a60268386da0d67c7d39fc7ff55/.config/nvim/lua/plugins/trailblazer.lua#L16
return plug({
  'LeonHeidelbach/trailblazer.nvim',
  cmd = {
    'TrailBlazerTrackBack',
    'TrailBlazerMoveToNearest',
    'TrailBlazerPeekMovePreviousUp',
    'TrailBlazerPeekMoveNextDown',
  },
  keys = {
    '<leader><space>',
    '<BS>',
    '<leader>m,',
    '<leader>m.',
    { '<leader>mn', '<cmd>TrailBlazerMoveToNearest<cr>',       desc = 'trail nearest' },
    '<leader>mt',
    { '<leader>ma', add_trail_mark_stack,                      desc = 'trailblazer: add stack' },
    { '<leader>md', delete_trail_mark_stack,                   desc = 'trailblazer: delete stack' },
    { '<leader>mg', function() get_available_stacks(true) end, desc = 'trailblazer: get stacks' },
    { '<leader>ms', '<Cmd>TrailBlazerSaveSession<CR>',         desc = 'trailblazer: save session' },
    { '<leader>ml', '<Cmd>TrailBlazerLoadSession<CR>',         desc = 'trailblazer: load session' },
  },
  init = function()
    local set = vim.keymap.set
    -- set('n', '<BS>', '<cmd>TrailBlazerTrackBack %<cr>', {
    --   silent = true,
    --   noremap = true,
    --   desc = 'Trace back in buf'
    -- })
    set('n', '<BS>', '<cmd>TrailBlazerTrackBack<cr>', {
      silent = true,
      noremap = true,
      desc = 'Trace back global'
    })
    set('n', '<D-j>', '<cmd>TrailBlazerPeekMoveNextDown %<cr>', {
      silent = true,
      noremap = true,
      desc = 'Trail next in buf',
    })
    set('n', '<D-k>', '<cmd>TrailBlazerPeekMovePreviousUp %<cr>', {
      silent = true,
      noremap = true,
      desc = 'Trail pre in buf',
    })
    set('n', '<D-S-j>', '<cmd>TrailBlazerPeekMoveNextDown<cr>', {
      silent = true,
      noremap = true,
      desc = 'Trail next global',
    })
    set('n', '<D-S-k>', '<cmd>TrailBlazerPeekMovePreviousUp<cr>', {
      silent = true,
      noremap = true,
      desc = 'Trail pre global',
    })
  end,
  opts = {
    -- hl_groups = {
    --
    -- },
    lang = "en",
    auto_save_trailblazer_state_on_exit = false,
    auto_load_trailblazer_state_on_enter = false,
    trail_options = {
      trail_mark_priority = 10001,
      --- Available modes to cycle through.
      available_trail_mark_modes = {
        "global_chron",
        "global_buf_line_sorted",
        "global_fpath_line_sorted",
        "global_chron_buf_line_sorted",
        "global_chron_fpath_line_sorted",
        "global_chron_buf_switch_group_chron",
        "global_chron_buf_switch_group_line_sorted",
        "buffer_local_chron",
        "buffer_local_line_sorted"
      },
      current_trail_mark_mode = "global_chron_buf_switch_group_chron",
      verbose_trail_mark_select = false,
      mark_symbol = "▢",
      newest_mark_symbol = "■",
      cursor_mark_symbol = "▣",
      next_mark_symbol = "↪",
      previous_mark_symbol = "↩",
      multiple_mark_symbol_counters_enabled = true,
      trail_mark_symbol_line_indicators_enabled = true,
      trail_mark_list_rows = 5,
      move_to_nearest_before_peek = false,
      move_to_nearest_before_peek_motion_directive_up = "up",
      move_to_nearest_before_peek_motion_directive_down = "down",
    },
    event_list = {
      "TrailBlazerTrailMarkStackSaved",
      "TrailBlazerCurrentTrailMarkStackChanged",
    },
    quickfix_mappings = {
      v = {
        actions = {
          qf_action_move_selected_trail_marks_down = "<C-k>",
          qf_action_move_selected_trail_marks_up = "<C-l>",
        }
      }
    },
    force_mappings = {
      nv = {
        motions = {
          new_trail_mark = '<leader><space>',
          toggle_trail_mark_list = '<leader>mt',
        },
        actions = {
          -- delete_all_trail_marks = '<A-L>',
          -- paste_at_last_trail_mark = '<A-p>',
          -- paste_at_all_trail_marks = '<A-P>',
          -- set_trail_mark_select_mode = '<A-t>',
          switch_to_next_trail_mark_stack = '<leader>m.',
          switch_to_previous_trail_mark_stack = '<leader>m,',
          -- set_trail_mark_stack_sort_mode = '<A-s>',
        },
      },
    },
  }
})
