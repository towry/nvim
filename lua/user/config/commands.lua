local create_cmd = vim.api.nvim_create_user_command

create_cmd(
  'TmuxRerun',
  function(opts)
    -- Retrieve the argument, which is the target pane index
    local index = opts.args

    -- Get the current tmux pane ID
    local current_pane = os.getenv('TMUX_PANE')

    -- Construct the tmux command to get the active pane index
    local tmux_active_pane_command = "tmux display-message -p '#{pane_index}'"

    -- Execute the tmux command and retrieve the active pane index
    local handle = io.popen(tmux_active_pane_command)
    local active_pane_index = handle:read("*a")
    handle:close()

    -- Trim whitespace from the active pane index
    active_pane_index = string.gsub(active_pane_index, "%s+", "")

    -- Run the tmux respawn-pane command only if the index is not the active one
    if active_pane_index ~= index then
      local tmux_respawn_command = "tmux respawn-pane -k -t " .. index
      os.execute(tmux_respawn_command)
    else
      print("Cannot respawn the active pane where Neovim resides.")
    end
  end,
  {
    nargs = 1, -- This command requires one argument (the pane index)
    desc = "Respawn a tmux pane with the given index if it's not the active one"
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
      "tmux split-window -d -p 40 -c '#{pane_current_path}' '%s'",
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
