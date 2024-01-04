local keymap = require('userlib.runtime.keymap')
local pathlib = require('userlib.runtime.path')
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
  -- Define the TmuxRerun command
  create_cmd('TmuxRerun', function(opts)
    -- Split the input arguments on '--' to separate the pane index and optional shell commands
    local args = vim.split(opts.args, '%s*%-%-%s*')
    local index = args[1] -- The pane index should be the first argument
    local shell_command = table.concat(vim.list_slice(args, 2), ' ') -- The rest is the optional shell command

    -- Get the current tmux pane ID
    local current_pane = os.getenv('TMUX_PANE')

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
    local tmux_split_command = string.format(
      [[tmux split-window -p 15 -c '#{pane_current_path}' 'tmux select-pane -T "%s" >/dev/null; tmux last-pane>/dev/null; %s ; cat']],
      user_command,
      user_command
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
      local cmds = string.format([[Make%s -f %s%s]], opts.bang and '!' or '', mk, target)
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
