local Buffer = require('libs.runtime.buffer')
local au = require('libs.runtime.au')

local M = {
  'nvim-treesitter/nvim-treesitter',
  build = function()
    if #vim.api.nvim_list_uis() == 0 then
      -- update sync if running headless
      vim.cmd.TSUpdateSync()
    else
      -- otherwise update async
      vim.cmd.TSUpdate()
    end
  end,
  keys = {
    { "<Enter>",    desc = "Init Increment selection" },
    { "<Enter>",    desc = "node node incremental selection",      mode = "x" },
    { "<BS>",       desc = "Decrement selection",                  mode = "x" },
    { '<leader>cr', desc = 'Smart rename/nvim-treesitter-refactor' },
  },
  dependencies = {
    'yioneko/nvim-yati',
    {
      'nvim-treesitter/nvim-treesitter-textobjects',
      init = function()
        -- PERF: no need to load the plugin, if we only need its queries for mini.ai
        local plugin = require("lazy.core.config").spec.plugins["nvim-treesitter"]
        local opts = require("lazy.core.plugin").values(plugin, "opts", false)
        local enabled = false
        if opts.textobjects then
          for _, mod in ipairs({ "move", "select", "swap", "lsp_interop" }) do
            if opts.textobjects[mod] and opts.textobjects[mod].enable then
              enabled = true
              break
            end
          end
        end
        if not enabled then
          require("lazy.core.loader").disable_rtp_plugin("nvim-treesitter-textobjects")
        end
      end,
    },
    'nvim-treesitter/nvim-treesitter-refactor',
    -- setting the commentstring option based on the cursor location in the file. The location is checked via treesitter queries.
    -- Vue files can have many different sections, each of which can have a different style for comments.
    'JoosepAlviste/nvim-ts-context-commentstring',
    'HiPhish/nvim-ts-rainbow2',
    -- vai to select current context!
    -- 'kiyoon/treesitter-indent-object.nvim',
  },
  event = { 'BufReadPost', 'BufNewFile' },
}

local disabled = function(lang, bufnr)
  -- local ft = vim.api.nvim_buf_get_option(bufnr, 'ft')
  local ft = vim.api.nvim_get_option_value("filetype", {
    buf = bufnr,
  })
  if vim.tbl_contains(vim.cfg.lang__treesitter_plugin_disable_on_filetypes or {}, ft) then
    return true
  end
  -- great than 100kb or lines great than 20000
  return vim.api.nvim_buf_line_count(bufnr) > 20000 or Buffer.getfsize(bufnr) > 100000
end

function M.config()
  require('nvim-treesitter.install').prefer_git = true
  require('nvim-treesitter.configs').setup({
    -- parser_install_dir = parser_install_dir,
    ensure_installed = vim.cfg.lang__treesitter_ensure_installed, -- one of "all", or a list of languages
    sync_install = false,                                         -- install languages synchronously (only applied to `ensure_installed`)
    auto_install = false,
    ignore_install = { 'all' },                                   -- list of parsers to ignore installing
    highlight = {
      disable = disabled,
      enable = vim.cfg.lang__treesitter_plugin_highlight,
      -- disable = { "c", "rust" },  -- list of language that will be disabled
      -- additional_vim_regex_highlighting = false,
    },
    incremental_selection = {
      enable = vim.cfg.lang__treesitter_plugin_incremental_selection,
      disable = disabled,
      keymaps = {
        init_selection = "<Enter>",
        node_incremental = "<Enter>",
        scope_incremental = false,
        node_decremental = "<BS>",
      },
    },
    indent = {
      -- use yati.
      -- enable = vim.cfg.lang__treesitter_plugin_indent,
      enable = not vim.cfg.lang__treesitter_plugin_yati,
      disable = disabled,
    },
    yati = {
      -- https://github.com/yioneko/nvim-yati
      enable = vim.cfg.lang__treesitter_plugin_yati,
      disable = disabled,
      default_lazy = true,
      default_fallback = 'auto',
      -- if ts.indent is truee, use below to suppress conflict warns.
      suppress_conflict_warning = true,
    },
    context_commentstring = {
      enable = vim.cfg.lang__treesitter_plugin_context_commentstring,
      enable_autocmd = false,
    },
    rainbow = {
      disable = disabled,
      enable = vim.cfg.lang__treesitter_plugin_rainbow,
      -- disable = { "jsx", "cpp" }, list of languages you want to disable the plugin for
      query = 'rainbow-parens',
      -- Highlight the entire buffer all at once
      strategy = require('ts-rainbow').strategy.global,
      max_file_lines = 8000,
    },
    refactor = {
      highlight_definitions = {
        enable = true,
        -- Set to false if you have an `updatetime` of ~100.
        clear_on_cursor_move = true,
      },
      highlight_current_scope = { enable = true },
      smart_rename = {
        enable = false,
        keymaps = {
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
        enable = vim.cfg.lang__treesitter_plugin_textobjects_move,
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
      enable = vim.cfg.lang__treesitter_plugin_textsubjects,
      lookahead = false,
      keymaps = {
        ['<cr>'] = 'textsubjects-smart', -- works in visual mode
      },
    },
  })
end

return M
