local create_cmd = vim.api.nvim_create_user_command

-- Define the TmuxRerun command
create_cmd(
  'TmuxRerun',
  function(opts)
    -- Split the input arguments on '--' to separate the pane index and optional shell commands
    local args = vim.split(opts.args, "%s*%-%-%s*")
    local index = args[1]                                            -- The pane index should be the first argument
    local shell_command = table.concat(vim.list_slice(args, 2), " ") -- The rest is the optional shell command

    -- Get the current tmux pane ID
    local current_pane = os.getenv('TMUX_PANE')

    -- Construct the tmux command to get the active pane index
    local tmux_active_pane_command = "tmux display-message -p '#{pane_index}'"

    -- Execute the tmux command and retrieve the active pane index
    local handle = io.popen(tmux_active_pane_command)
    if not handle then
      vim.notify("failed to get active pane index", vim.log.levels.ERROR);
      return
    end
    local active_pane_index = handle:read("*a")
    handle:close()

    -- Trim whitespace from the active pane index
    active_pane_index = string.gsub(active_pane_index, "%s+", "")

    -- Run the tmux respawn-pane command only if the index is not the active one
    if active_pane_index ~= index then
      local tmux_respawn_command = "tmux respawn-pane -k -t " .. index .. " -c '#{pane_current_path}'"
      if shell_command and shell_command ~= "" then
        -- Append the optional shell command, properly escaped
        tmux_respawn_command = tmux_respawn_command .. " " .. vim.fn.shellescape(shell_command .. " ; cat", true)
      end
      os.execute(tmux_respawn_command)
    else
      print("Cannot respawn the active pane where Neovim resides.")
    end
  end,
  {
    nargs = "+",           -- This command allows one or more arguments
    desc = "Respawn a tmux pane with the given index, optionally running the specified shell command",
    complete = "shellcmd", -- Use shell command completion
  }
)

create_cmd(
  'TmuxRun',
  function(opts)
    -- Retrieve the command to run in the new tmux pane
    local user_command = table.concat(opts.fargs, " ")

    -- Ensure that the command is not empty
    if user_command == nil or user_command == "" then
      print("No command provided to run in tmux split-window.")
      return
    end

    -- Construct the tmux command to split the window and run the user's command
    local tmux_split_command = string.format(
      "tmux split-window -d -p 15 -c '#{pane_current_path}' '%s ; cat'",
      user_command
    )

    -- Execute the tmux command
    local success, _, _ = os.execute(tmux_split_command)
    if not success then
      print("Failed to execute tmux split-window command.")
    end
  end,
  {
    nargs = "+",           -- This command requires at least one argument (the command to run)
    desc = "Run a command in a new tmux split-window",
    complete = "shellcmd", -- Use shell command completion
  }
)
