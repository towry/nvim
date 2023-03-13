local M = {}

M.setup_toggleterm = function()
  require('toggleterm').setup({
    -- size can be a number or function which is passed the current terminal
    size = function(term)
      if term.direction == 'horizontal' then
        return 15
      elseif term.direction == 'vertical' then
        return vim.o.columns * 0.4
      end
    end,
    -- f24 = shift + f12
    open_mapping = [[<F24>]],
    hide_numbers = true, -- hide the number column in toggleterm buffers
    highlights = {
      -- highlights which map to a highlight group name and a table of it's values
      -- NOTE: this is only a subset of values, any group placed here will be set for the terminal window split
      Normal = {
        link = 'Normal',
      },
      NormalFloat = {
        link = 'Normal',
      },
      FloatBorder = {
        -- guifg = <VALUE-HERE>,
        -- guibg = <VALUE-HERE>,
        link = 'FloatBorder',
      },
    },
    shade_filetypes = {},
    shade_terminals = true,
    shading_factor = 1, -- the degree by which to darken to terminal colour, default: 1 for dark backgrounds, 3 for light
    start_in_insert = true,
    insert_mappings = true, -- whether or not the open mapping applies in insert mode
    persist_size = false,
    direction = 'horizontal', -- | 'horizontal' | 'window' | 'float',
    close_on_exit = true, -- close the terminal window when the process exits
    shell = vim.o.shell, -- change the default shell
    -- This field is only relevant if direction is set to 'float'
    float_opts = {
      -- The border key is *almost* the same as 'nvim_win_open'
      -- see :h nvim_win_open for details on borders however
      -- the 'curved' border is a custom border type
      -- not natively supported but implemented in this plugin.
      border = 'curved', -- single/double/shadow/curved
      winblend = 4,
    },
    winbar = {
      enabled = false,
    },
  })
end

M.init_toggleterm = function()
  Ty.set_terminal_keymaps = function()
    local opts = { noremap = true }
    vim.api.nvim_buf_set_keymap(0, 't', '<C-\\>', [[<C-\><C-n>:ToggleTerm<CR>]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<esc>', [[<C-\><C-n>]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<C-h>', [[<C-\><C-n><C-W>h]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<C-j>', [[<C-\><C-n><C-W>j]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<C-k>', [[<C-\><C-n><C-W>k]], opts)
    vim.api.nvim_buf_set_keymap(0, 't', '<C-l>', [[<C-\><C-n><C-W>l]], opts)
  end
  vim.cmd('autocmd! TermOpen term://*toggleterm#* lua Ty.set_terminal_keymaps()')
  vim.keymap.set('n', '<C-\\>', function()
    if vim.tbl_contains({
      'NvimTree',
      'lazy',
    }, vim.bo.filetype) then return end
    vim.cmd([[ToggleTerm direction=float]])
  end, {
    desc = 'toggle term',
    silent = true,
  })
end

M.option_term_flatten = {
  callbacks = {
    pre_open = function()
      -- Close toggleterm when an external open request is received
      require("toggleterm").toggle(0)
    end,
    post_open = function(bufnr, winnr, ft)
      if ft == "gitcommit" then
        -- If the file is a git commit, create one-shot autocmd to delete it on write
        -- If you just want the toggleable terminal integration, ignore this bit and only use the
        -- code in the else block
        vim.api.nvim_create_autocmd(
          "BufWritePost",
          {
            buffer = bufnr,
            once = true,
            callback = function()
              -- This is a bit of a hack, but if you run bufdelete immediately
              -- the shell can occasionally freeze
              vim.defer_fn(
                function()
                  vim.api.nvim_buf_delete(bufnr, {})
                end,
                50
              )
            end
          }
        )
      else
        -- If it's a normal file, then reopen the terminal, then switch back to the newly opened window
        -- This gives the appearance of the window opening independently of the terminal
        require("toggleterm").toggle(0)
        vim.api.nvim_set_current_win(winnr)
      end
    end,
    block_end = function()
      -- After blocking ends (for a git commit, etc), reopen the terminal
      require("toggleterm").toggle(0)
    end
  },
  window = {
    open = "current",
  }
}

return M
