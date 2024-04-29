local au = require('userlib.runtime.au')
local M = {}

---@param text string?
M.open = function(text)
  if not text or text == '' then
    return
  end

  require('userlib.mini.clue').shortly_open(function(set, unset)
    set('n', '1', '<cmd>echo expand("%")<cr>', { desc = 'Query >:' .. text })

    set('n', 'f', function()
      if vim.cfg.plugin_fzf_or_telescope == 'fzf' then
        require('userlib.fzflua').files({
          cwd_header = true,
          query = text,
        })
      else
        require('userlib.telescope.pickers').project_files({
          -- cwd = new_cwd,
        })
      end
      unset()
    end, {
      desc = 'Open files',
    })

    set('n', 'p', function()
      if vim.cfg.plugin_fzf_or_telescope == 'telescope' then
        require('telescope').extensions.file_browser.file_browser(require('userlib.telescope.themes').get_dropdown({
          files = false,
          disable_devicons = true,
          use_fd = true,
          display_stat = false,
          hide_parent_dir = true,
          respect_gitignore = true,
          hidden = true,
          previewer = false,
          depth = 3,
          git_status = false,
          default_text = text,
          -- cwd = new_cwd,
        }))
      else
        require('userlib.fzflua').folders({
          -- cwd = new_cwd,
          cwd_header = true,
          query = text,
        })
      end
      unset()
    end, {
      desc = 'Open folders',
    })
    set('n', 's', function()
      if vim.cfg.plugin_fzf_or_telescope == 'fzf' then
        require('fzf-lua').live_grep({
          -- cwd = new_cwd,
          cwd_header = true,
          query = text,
        })
      else
        require('telescope.builtin').live_grep({
          default_text = text,
          -- cwd = new_cwd,
          prompt_title = 'Live Grep in ' .. vim.fn.fnamemodify(vim.uv.cwd() or '', ':t'),
        })
      end
      unset()
    end, {
      desc = 'Search content',
    })

    set('n', 'g', function()
      require('rgflow').open(text, nil)
    end, {
      desc = 'Grep on from',
    })

    set('n', 'r', function()
      require('fzf-lua').oldfiles({
        query = text,
        cwd_header = true,
        -- cwd = new_cwd,
        cwd_only = true,
        winopts = {
          fullscreen = false,
        },
      })
      unset()
    end, {
      desc = 'Open recent',
    })
  end)
end

return M
