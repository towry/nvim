local Buffer = require('ty.core.buffer')
local M = {}

local disabled_fts = {
  "NvimTree",
}

local disabled = function(lang, bufnr)
  local ft = vim.api.nvim_buf_get_option(bufnr, 'ft')
  if vim.tbl_contains(disabled_fts, ft) then
    return true
  end
  -- great than 100kb or lines great than 20000
  return vim.api.nvim_buf_line_count(bufnr) > 20000 or Buffer.getfsize(bufnr) > 100000
end

M.setup = function()
  local config = require('ty.core.config').langsupport.treesitter or {}
  require('nvim-treesitter.install').prefer_git = true
  require('nvim-treesitter.configs').setup({
    -- parser_install_dir = parser_install_dir,
    ensure_installed = config.ensure_installed, -- one of "all", or a list of languages
    sync_install = false,                       -- install languages synchronously (only applied to `ensure_installed`)
    auto_install = false,
    ignore_install = { 'all' },                 -- list of parsers to ignore installing
    highlight = {
      disable = disabled,
      enable = config.enable_highlight,
      -- disable = { "c", "rust" },  -- list of language that will be disabled
      -- additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
      enable = config.enable_incremental_selection,
      disable = disabled,
      keymaps = {
        init_selection = '<leader>gnn',
        node_incremental = '<leader>gnr',
        scope_incremental = '<leader>gne',
        node_decremental = '<leader>gnt',
      },
    },
    indent = {
      -- use yati.
      enable = config.enable_indent,
      disable = disabled,
    },
    yati = {
      -- https://github.com/yioneko/nvim-yati
      enable = config.enable_yati,
      disable = disabled,
      default_lazy = true,
      default_fallback = 'auto',
      -- if ts.indent is truee, use below to suppress conflict warns.
      -- suppress_conflict_warning = true,
    },
    context_commentstring = {
      enable = config.enable_context_commentstring,
      enable_autocmd = false,
    },
    rainbow = {
      disable = disabled,
      enable = config.enable_rainbow,
      -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
      extended_mode = true, -- Also highlight non-bracket delimiters like html tags, boolean or table: lang -> boolean
      max_file_lines = 8000,
    },
    refactor = {
      smart_rename = {
        enable = false,
        client = {
          smart_rename = '<leader>cr',
        },
      },
      navigation = {
        enable = false,
        keymaps = {
          -- goto_definition = "gd",
          -- list_definitions = "gnD",
          -- list_definitions_toc = "gO",
          -- goto_next_usage = "<a-*>",
          -- goto_previous_usage = "<a-#>",
        },
      },
    },
    textobjects = {
      move = {
        disable = disabled,
        enable = config.enable_textobjects_move,
        set_jumps = true, -- whether to set jumps in the jumplist
        goto_next_start = {
          [']]'] = '@function.outer',
          [']m'] = '@class.outer',
        },
        goto_next_end = {
          [']['] = '@function.outer',
          [']M'] = '@class.outer',
        },
        goto_previous_start = {
          ['[['] = '@function.outer',
          ['[m'] = '@class.outer',
        },
        goto_previous_end = {
          ['[]'] = '@function.outer',
          ['[M'] = '@class.outer',
        },
      },
      select = {
        disable = disabled,
        enable = true,
        -- Automatically jump forward to textobj, similar to targets.vim
        lookahead = true,
        keymaps = {
          -- You can use the capture groups defined in textobjects.scm
          ['af'] = '@function.outer',
          ['if'] = '@function.inner',
          ['ac'] = '@class.outer',
          ['ic'] = '@class.inner',
        },
      },
      swap = {
        enable = false,
        swap_next = {
          -- FIXME: keymap
          -- ["<S-~>"] = "@parameter.inner",
        },
      },
    },
    textsubjects = {
      disable = disabled,
      -- has issues.
      enable = config.enable_textsubjects,
      keymaps = {
        ['<cr>'] = 'textsubjects-smart', -- works in visual mode
      },
    },
  })
end

return M
