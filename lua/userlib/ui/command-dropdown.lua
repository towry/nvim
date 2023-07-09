--- https://github.com/nvim-telescope/telescope-ui-select.nvim/blob/master/lua/telescope/_extensions/ui-select.lua
--- credits to softinio/nvim-metals
local has_telescope, _ = pcall(require, "telescope")

if not has_telescope then
  local msg = "Telescope must be installed to use this functionality (https://github.com/nvim-telescope/telescope.nvim)"
  print(msg)
  return
end

local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")
local conf = require("telescope.config").values
local entry_display = require("telescope.pickers.entry_display")
local finders = require("telescope.finders")
local themes = require("telescope.themes")
local pickers = require("telescope.pickers")

local function command_entry_maker(max_width)
  local make_display = function(en)
    local displayer = entry_display.create({
      separator = " ",
      items = {
        { width = max_width },
        { remaining = true },
      },
    })

    return displayer({
      { en.label, "Type" },
      { en.hint, "Comment" },
    })
  end

  return function(entry)
    return {
      command = entry[1],
      ordinal = entry.label .. (entry.hint or ''),
      hint = entry.hint or '',
      label = entry.label or '',
      display = make_display,
    }
  end
end

local function get_max_width(commands)
  local max = 0
  for _, value in ipairs(commands) do
    max = #value.label > max and #value.label or max
  end
  return max
end

---@opts {label:string,hint?:string}
local function create_item(opts)
  return opts
end

---@param ouropts table
---     - items ({label:string,hint?:string}[])
---     - on_select function ((item) -> ())
local function commands(ouropts, opts)
  ouropts = ouropts or {}
  opts = themes.get_dropdown(vim.tbl_extend('force', {
    previewer = false,
  }, opts or {}))

  local function execute_command(bufnr)
    local selection = action_state.get_selected_entry(bufnr)
    actions.close(bufnr)
    if type(selection.command) == 'string' then
      vim.schedule(function()
        vim.cmd(selection.command)
      end)
      return
    end
    if ouropts.on_select then
      ouropts.on_select(selection)
    end
  end

  pickers.new(opts, {
    finder = finders.new_table({
      results = ouropts.items,
      entry_maker = command_entry_maker(get_max_width(ouropts.items)),
    }),
    sorter = conf.generic_sorter(opts),
    attach_mappings = function(_, map)
      map("i", "<CR>", execute_command)
      map("n", "<CR>", execute_command)
      return true
    end,
  }):find()
end

return {
  select = commands,
  create_item = create_item,
}
