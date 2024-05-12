local au = require('userlib.runtime.au')
local plug = require('userlib.runtime.pack').plug

local commands = {
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
}

return plug({
  'epwalsh/obsidian.nvim',
  version = '*',
  lazy = true,
  enabled = true,
  keys = {
    {
      '<leader>no',
      function()
        require('legendary').find({
          itemgroup = 'obsidian',
        })
      end,
      desc = 'Obsidian switch note',
    },
  },
  cmd = commands,

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
    open_notes_in = 'vsplit',
    attachments = {
      img_folder = 'meta/assets',
    },
  },
  init = au.schedule_lazy(function()
    require('userlib.legendary').register('obsidian', function(lg)
      local cmds = vim.tbl_map(function(item)
        return {
          ':' .. item,
          description = 'Obsidian: ' .. item,
        }
      end, commands)

      local funcs = {
        {
          function()
            if not vim.g.obsidian_personal_location and not vim.env['OBSIDIAN_DEFAULT_VAULT'] then
              vim.notify('No obsidian vault folder', vim.log.levels.ERROR)
              return
            end
            require('userlib.fzflua').grep({
              prompt = 'Grep in Obsidian(Personal): ',
              cwd = vim.g.obsidian_personal_location or vim.env['OBSIDIAN_DEFAULT_VAULT'],
            })
          end,
          desc = 'Grep inside personal obsidian notes',
        },
      }

      lg.funcs(funcs)

      lg.commands({
        itemgroup = 'obsidian',
        description = 'Obsidian',
        commands = cmds,
      })
    end)
  end),
  config = function(_, opts)
    local workspaces = opts.workspaces or {}

    if vim.g.obsidian_personal_location or vim.env['OBSIDIAN_DEFAULT_VAULT'] then
      --- private vault location
      vim.list_extend(workspaces, {
        {
          name = 'personal',
          path = vim.g.obsidian_personal_location or vim.env['OBSIDIAN_DEFAULT_VAULT'],
        },
      })
    end

    opts.workspaces = workspaces

    require('obsidian').setup(opts)
  end,
  init = function()
    vim.g.obsidian_personal_location = vim.g.obsidian_personal_location or vim.env['OBSIDIAN_DEFAULT_VAULT']
    if not vim.g.obsidian_personal_location then
      return
    end
  end,
})
