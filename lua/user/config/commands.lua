local keymap = require('userlib.runtime.keymap')
local create_cmd = vim.api.nvim_create_user_command
local package_path_updated = false

local function update_background_from_script()
  package.loaded['lua.settings_env'] = nil
  if not package_path_updated then
    package.path = package.path .. ';' .. vim.fn.fnamemodify(vim.env.MYVIMRC, ':h') .. '/?.lua'
    package_path_updated = true
  end
  pcall(require, 'lua.settings_env')
end

create_cmd('Grep', function(params)
  -- Insert args at the '$*' in the grepprg
  local cmd, num_subs = vim.o.grepprg:gsub('%$%*', params.args)
  if num_subs == 0 then
    cmd = cmd .. ' ' .. params.args
  end
  local overseer = require('overseer')
  local task = overseer.new_task({
    cmd = vim.fn.expandcmd(cmd),
    components = {
      {
        'on_output_quickfix',
        errorformat = vim.o.grepformat,
        open = not params.bang,
        open_height = 8,
        items_only = true,
      },
      -- We don't care to keep this around as long as most tasks
      { 'on_complete_dispose', timeout = 30 },
      'default',
    },
  })
  task:start()
end, {
  nargs = '+',
  bang = true,
  complete = 'file',
})

create_cmd('ToggleDark', function()
  local old_mode = vim.opt.background:get()
  update_background_from_script()
  if old_mode ~= vim.opt.background:get() then
    -- just sync the changes.
    return
  end

  local mode = old_mode == 'dark' and 'light' or 'dark'

  local cmds =
    string.format([[:silent !python3 %s %s]], vim.fn.expand('$HOME/.dotfiles/conf/commands/color_mode.py'), mode)
  vim.cmd(cmds)
  vim.cmd(':silent OnDarkMode')
end, {})

create_cmd('OnDarkMode', update_background_from_script, {})

if vim.env['TMUX'] ~= nil then
  table.insert(vim.g.miniclues, {
    { mode = 'n', keys = '<LocalLeader>x', desc = '+Tmux' },
  })
  -- Define the TmuxRerun command
  create_cmd('TmuxRerun', function(opts)
    -- Split the input arguments on '--' to separate the pane index and optional shell commands
    local args = vim.split(opts.args, '%s*%-%-%s*')
    local index = args[1] -- The pane index should be the first argument
    local shell_command = table.concat(vim.list_slice(args, 2), ' ') -- The rest is the optional shell command

    -- Get the current tmux pane ID
    -- local current_pane = os.getenv('TMUX_PANE')

    -- Construct the tmux command to get the active pane index
    local tmux_active_pane_command = "tmux display-message -p '#{pane_index}'"

    -- Execute the tmux command and retrieve the active pane index
    local handle = io.popen(tmux_active_pane_command)
    if not handle then
      vim.notify('failed to get active pane index', vim.log.levels.ERROR)
      return
    end
    local active_pane_index = handle:read('*a')
    handle:close()

    -- Trim whitespace from the active pane index
    active_pane_index = string.gsub(active_pane_index, '%s+', '')

    -- Run the tmux respawn-pane command only if the index is not the active one
    if active_pane_index ~= index then
      local tmux_respawn_command = 'tmux respawn-pane -k -t ' .. index .. " -c '#{pane_current_path}'"
      if shell_command and shell_command ~= '' then
        -- Append the optional shell command, properly escaped
        tmux_respawn_command = tmux_respawn_command .. ' ' .. vim.fn.shellescape(shell_command .. ' ; cat', true)
      end
      os.execute(tmux_respawn_command)
    else
      print('Cannot respawn the active pane where Neovim resides.')
    end
  end, {
    nargs = '+', -- This command allows one or more arguments
    desc = 'Respawn a tmux pane with the given index, optionally running the specified shell command',
    complete = 'shellcmd', -- Use shell command completion
  })
  keymap.set('n', '<localleader>xr', ':TmuxRerun', {
    noremap = false,
    silent = false,
    desc = 'Start tmux rerun',
  })

  create_cmd('TmuxRun', function(opts)
    -- Retrieve the command to run in the new tmux pane
    local user_command = table.concat(opts.fargs, ' ')

    -- Ensure that the command is not empty
    if user_command == nil or user_command == '' then
      print('No command provided to run in tmux split-window.')
      return
    end

    -- Construct the tmux command to split the window and run the user's command
    -- tmux >= 3.4 require -l to specific percentage size.
    local tmux_split_command = string.format(
      [[tmux split-window -l %s -c '#{pane_current_path}' %s]],
      '5%',
      vim.fn.shellescape('tmux last-pane>/dev/null; ' .. user_command .. '; cat')
    )

    -- Execute the tmux command
    local success, _, _ = os.execute(tmux_split_command)
    if not success then
      print('Failed to execute tmux split-window command.')
    end
  end, {
    nargs = '+', -- This command requires at least one argument (the command to run)
    desc = 'Run a command in a new tmux split-window',
    complete = 'shellcmd', -- Use shell command completion
  })
  keymap.set('n', '<localleader>xx', ':TmuxRun', {
    noremap = false,
    silent = false,
    desc = 'TmuxRun',
  })
end

create_cmd('TryMake', function(opts)
  local pathlib = require('userlib.runtime.path')
  local cwd = vim.uv.cwd()
  local target = opts.fargs[1]
  if target == nil then
    target = ''
  else
    target = ' ' .. target
  end
  if vim.bo.buftype == '' then
    cwd = vim.fn.expand('%:p:h')
  end
  pathlib.search_ancestors(cwd, function(dir)
    if pathlib.is_home_dir(dir) then
      vim.notify('Makefile not found, homedir reached.')
      return true
    end
    if type(dir) ~= 'string' then
      vim.notify('invalid path found, return')
      return true
    end
    local mk = pathlib.join(dir, 'Makefile')
    if vim.fn.filereadable(mk) == 1 then
      local cwd = vim.uv.cwd()
      vim.cmd.lcd(dir)
      local cmds = string.format([[OverMake%s -f %s%s]], opts.bang and '!' or '', mk, target)
      vim.cmd(cmds)
      vim.cmd.lcd(cwd)
      return true
    end
  end)
end, {
  nargs = '*',
  bang = true,
  desc = 'Find makefile and run',
})

-- accept an argument as filename
create_cmd('Profile', function(opts)
  if opts.bang then
    Ty.StopProfile()
  else
    Ty.StartProfile(opts.fargs[1] or nil)
  end
end, {
  nargs = '?',
  bang = true,
  desc = 'Start or stop profile',
})

create_cmd('OpenProfileView', function()
  vim.ui.open('https://www.speedscope.app/')
end, {
  desc = 'Open online profile view',
})

create_cmd('Fixmes', function()
  require('userlib.finder').grep_keywords({ 'FIXME:', 'fixme!' })
end, {
  desc = 'List fixmes',
})

create_cmd('Comtag', function(opts)
  if not vim.tbl_contains({
    'NOTE',
    'TODO',
    'FIXME',
    'DEBUG',
  }, opts.args) then
    return
  end
  require('userlib.finder').grep_keywords({ opts.args })
end, {
  desc = 'List fixmes',
  nargs = '?',
  complete = function()
    return {
      'NOTE',
      'TODO',
      'FIXME',
      'DEBUG',
    }
  end,
})

-- Make with overseer
create_cmd('OverMake', function(params)
  -- Insert args at the '$*' in the makeprg
  local cmd, num_subs = vim.o.makeprg:gsub('%$%*', params.args)
  if num_subs == 0 then
    cmd = cmd .. ' ' .. params.args
  end
  --- expandcmd raise error about backtick like cmd: Git commit -m "some
  --- `backtick`"
  cmd = vim.fn.expandcmd(vim.fn.escape(cmd, '`'))
  local task = require('overseer').new_task({
    cmd = cmd,
    components = {
      { 'on_output_quickfix', open = not params.bang, open_height = 8 },
      'default',
    },
  })

  task:start()
  vim.schedule(function()
    vim.api.nvim_echo({ { 'OverMake: ', 'InfoFloat' }, { cmd, 'Comment' } }, true, {})
  end)
end, {
  desc = 'Run your makeprg as an Overseer task',
  nargs = '*',
  bang = true,
})

-- Dispatch with overseer
create_cmd('OverDispatch', function(params)
  local cmd = vim.trim(params.args or '')
  if cmd == '' and vim.b.over_dispatch then
    cmd = vim.b.over_dispatch
  end
  vim.b.over_dispatch = cmd
  local expanded_cmd = vim.fn.expandcmd(vim.fn.escape(cmd, '`'))
  local task = require('overseer').new_task({
    cmd = expanded_cmd,
    components = {
      { 'on_output_quickfix', open = not params.bang, open_height = 8 },
      'default',
    },
  })
  task:start()

  local echo_label = params.bang and 'OverDispatch[!]: ' or 'OverDispatch: '
  vim.schedule(function()
    vim.api.nvim_echo({ { echo_label, 'InfoFloat' }, { expanded_cmd, 'Comment' } }, true, {})
  end)
end, {
  desc = 'Run your cmd as an Overseer task',
  nargs = '*',
  bang = true,
})

create_cmd('Yazi', function()
  require('userlib.terminal.yazi').toggle()
end, {
  desc = 'Open yazi',
  nargs = '*',
})

-- used in keymap to quickly close popup and quickfix in esc press.
create_cmd('PcloseNextEsc', function()
  vim.g.escape_cmd = 'pclose'
end, {
  nargs = 0,
  bar = true,
})
create_cmd('QfCloseNextEsc', function()
  vim.g.escape_cmd = 'cclose'
end, {
  nargs = 0,
  bar = true,
})

create_cmd('Diffbufnr', function(params)
  vim.cmd(([[tab exec "diffsplit" bufname(%s)]]):format(params.args))
end, {
  nargs = 1,
})

create_cmd('Qwrite', function()
  vim.cmd('noau wa')
  vim.cmd('MakeSession')
  vim.cmd('qa')
end, {
  nargs = 0,
  desc = 'Write all and save session and exit',
})

create_cmd('LockTcd', function()
  require('userlib.runtime.utils').lock_tcd()
end, {
  desc = 'Lock tcd',
})
create_cmd('UnlockTcd', function()
  require('userlib.runtime.utils').unlock_tcd()
  --- update new cwd after unlock
  vim.schedule(function()
    vim.cmd('ProjectRoot')
  end)
end, {
  desc = 'Unlock tcd',
})

create_cmd('Cdin', function(params)
  local cwd = params.args and vim.trim(vim.fn.fnamemodify(params.args, ':p') or '')
  if cwd == '' or not cwd then
    cwd = vim.uv.cwd()
  end
  vim.cfg.runtime__starts_cwd = require('userlib.runtime.path').remove_path_last_separator(cwd)
  vim.cmd.cd(vim.b.osc7_dir or cwd)
end, {
  nargs = '*',
  complete = 'dir',
  bang = true,
  desc = 'Change root cwd',
})

create_cmd('CloseAll', function()
  vim.cmd('silent! windo close')
  vim.cmd('bufdo bw')
end, {
  desc = 'Close all buffers and windows',
})
