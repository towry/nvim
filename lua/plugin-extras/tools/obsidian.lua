local plug = require('userlib.runtime.pack').plug

return plug({
  'epwalsh/obsidian.nvim',
  version = '*',
  lazy = true,
  ft = 'markdown',
  cmd = {
    'ObsidianOpen',
    'ObsidianNew',
    'ObsidianQuickSwitch',
    'ObsidianFollowLink',
    'ObsidianBacklinks',
    'ObsidianTags',
    'ObsidianToday',
    'ObsidianYesterday',
    'ObsidianTomorrow',
    'ObsidianDailies',
    'ObsidianSearch',
    'ObsidianLink',
    'ObsidianLinkNew',
    'ObsidianLinks',
    'ObsidianExtractNote',
    'ObsidianWorkspace',
    'ObsidianPasteImg',
    'ObsidianRename',
  },

  dependencies = {
    -- Required.
    'nvim-lua/plenary.nvim',
    'nvim-telescope/telescope.nvim',
  },
  opts = {
    ui = {
      enable = false,
    },
    notes_subdir = 'fleets',
    log_level = vim.log.levels.WARN,
    workspaces = {},
    attachments = {
      img_folder = 'meta/assets',
    },
  },
  config = function(_, opts)
    local workspaces = opts.workspaces or {}

    if vim.g.obsidian_personal_location then
      --- private vault location
      vim.list_extend(workspaces, {
        {
          name = 'personal',
          path = vim.g.obsidian_personal_location,
        },
      })
    end

    opts.workspaces = workspaces

    require('obsidian').setup(opts)
  end,
})
