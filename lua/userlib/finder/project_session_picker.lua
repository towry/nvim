local M = {}
local finders = require("telescope.finders")
local pickers = require("telescope.pickers")
local telescope_config = require("telescope.config").values
local actions = require("telescope.actions")
local state = require("telescope.actions.state")
local builtin = require("telescope.builtin")
local entry_display = require("telescope.pickers.entry_display")
local history = require("project_nvim.utils.history")


local function create_finder()
  local results = history.get_session_projects()

  -- Reverse results
  for i = 1, math.floor(#results / 2) do
    results[i], results[#results - i + 1] = results[#results - i + 1], results[i]
  end
  local displayer = entry_display.create({
    separator = " ",
    items = {
      {
        width = 30,
      },
      {
        remaining = true,
      },
    },
  })

  local function make_display(entry)
    return displayer({ entry.name, { entry.value, "Comment" } })
  end

  return finders.new_table({
    results = results,
    entry_maker = function(entry)
      local name = vim.fn.fnamemodify(entry, ":t")
      return {
        display = make_display,
        name = name,
        value = entry,
        ordinal = name .. " " .. entry,
      }
    end,
  })
end

local function session_projects(opts)
  opts = opts or {}

  pickers.new(opts, require('telescope.themes').get_dropdown({
    prompt_title = "Session Projects",
    finder = create_finder(),
    previewer = false,
    sorter = telescope_config.generic_sorter(opts),
    attach_mappings = function(prompt_bufnr, map)
      map('i', '<C-g>', function()
        -- open folders picker.
        actions.close(prompt_bufnr)
        require('telescope').extensions.file_browser.file_browser({
          files = false,
          display_stat = false,
          use_fd = true,
          hide_parent_dir = true,
          previewer = false,
          cwd = vim.cfg.runtime__starts_cwd,
        })
      end)
      local on_project_selected = function()
        local entry_path = state.get_selected_entry().value
        if not entry_path then return end
        local new_cwd = entry_path

        require('userlib.hydra.folder-action').open(new_cwd, prompt_bufnr)
      end
      actions.select_default:replace(on_project_selected)
      return true
    end,
  })):find()
end

return {
  session_projects = session_projects,
}
