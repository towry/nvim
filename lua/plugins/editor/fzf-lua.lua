local M = {}

local function get_last_query()
  local fzflua = require('fzf-lua')
  return vim.trim(fzflua.config.__resume_data.last_query or '')
end

---@param no_buffers? boolean
function M.buffers_or_recent(no_buffers)
  local fzflua = require('fzf-lua')
  local bufopts = {
    filename_first = true,
    sort_lastused = true,
    show_unloaded = false,
    winopts = {
      height = 0.3,
      fullscreen = false,
      preview = {
        hidden = 'hidden',
      },
    },
  }
  local oldfiles_opts = {
    prompt = ' Recent: ',
    cwd = LazyVim.root.cwd(),
    cwd_only = true,
    include_current_session = true,
    winopts = {
      height = 0.3,
      fullscreen = false,
      preview = {
        hidden = 'hidden',
      },
    },
    keymap = {},
  }
  local buffers_actions = {}

  local oldfiles_actions = {
    actions = {
      ['ctrl-e'] = function()
        return fzflua.buffers(vim.tbl_extend('force', {
          query = get_last_query(),
        }, bufopts, buffers_actions))
      end,
      ['ctrl-f'] = function()
        local query = get_last_query()
        if query == '' or not query then
          vim.notify('please provide query before switch to find files mode.')
          return
        end

        M.files({
          cwd = oldfiles_opts.cwd,
          query = query,
        })
      end,
    },
  }
  buffers_actions = {
    actions = {
      ['ctrl-e'] = function()
        fzflua.oldfiles(vim.tbl_extend('force', {
          query = get_last_query(),
        }, oldfiles_opts, oldfiles_actions))
      end,
    },
  }

  local count = #vim.fn.getbufinfo({ buflisted = 1 })
  if no_buffers or count <= 1 then
    --- open recent.
    fzflua.oldfiles(vim.tbl_extend('force', {}, oldfiles_opts, oldfiles_actions))
    return
  end
  local _bo = vim.tbl_extend('force', {}, bufopts, buffers_actions)
  return require('fzf-lua').buffers(_bo)
end

return {
  'ibhagwan/fzf-lua',
  keys = {
    {
      '<localleader>,',
      M.buffers_or_recent,
      desc = 'Buffers or recent buffers',
    },
  },
  opts = function(_, opts)
    return vim.tbl_deep_extend('force', opts, {
      defaults = {
        formatter = 'path.filename_first',
      },
      winopts = {
        border = vim.g.cfg_border_style,
        preview = {
          delay = 150,
          layout = 'flex',
          flip_columns = 240,
          horizontal = 'right:45%',
          vertical = 'down:40%',
          winopts = {
            cursorlineopt = 'line',
            foldcolumn = 0,
          },
        },
      },
      fzf_colors = false,
      fzf_opts = {
        ['--ansi'] = '',
        ['--info'] = 'inline',
        ['--height'] = '100%',
        ['--layout'] = 'reverse',
        ['--margin'] = '0%',
        ['--padding'] = '0%',
        ['--border'] = 'none',
        ['--cycle'] = '',
        ['--no-separator'] = '',
      },
    })
  end,
}
