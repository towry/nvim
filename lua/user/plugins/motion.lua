local plug = require('libs.runtime.pack').plug
local cmd = require('libs.runtime.keymap').cmdstr
local au = require('libs.runtime.au')
local enable_flash = true

plug({
  {
    'jinh0/eyeliner.nvim',
    enabled = not enable_flash,
    keys = {
      'f',
      'F',
      't',
      'T',
    },
    opts = {
      highlight_on_key = true, -- show highlights only after keypress
      dim = true
    },
    config = function(_, opts)
      -- local au = require('libs.runtime.au')

      require('eyeliner').setup(opts)

      au.register_event(au.events.AfterColorschemeChanged, {
        name = 'update_eyeliner_hl',
        immediate = true,
        callback = function()
          vim.api.nvim_set_hl(0, 'EyelinerPrimary', { bold = true, underline = true })
          vim.api.nvim_set_hl(0, 'EyelinerSecondary', { underline = true })
        end,
      })
    end,
  },
  {
    -- jump html tags.
    'harrisoncramer/jump-tag',
    keys = {
      {
        '[tp', cmd([[lua require('jump-tag').jumpParent()]]), desc = 'Jump to parent tag',
      },
      {
        '[tc', cmd([[lua require('jump-tag').jumpChild()]]), desc = 'Jump to child tag'
      },
      {
        '[t]', cmd([[lua require('jump-tag').jumpNextSibling()]]), desc = 'Jump to next tag'
      },
      {
        '[t[', cmd([[lua require('jump-tag').jumpPrevSibling()]]), desc = 'Jump to prev tag'
      }
    },
    dependencies = {
      'nvim-treesitter/nvim-treesitter',
    },
  },
  {
    {
      'ggandor/leap.nvim',
      enabled = not enable_flash,
      dependencies = {
        'tpope/vim-repeat',
      },
      keys = { { 's' }, { 'S' }, { 'gs' }, { 'f' }, { 'F' }, { 'vs' }, { 'ds' } },
      config = function()
        local leap = require('leap')
        -- local au = require('libs.runtime.au')

        leap.opts.highlight_unlabeled_phase_one_targets = true
        leap.opts.substitute_chars = {
          ['\r'] = '',
          [' '] = '␣',
        }
        leap.add_default_mappings()
        leap.init_highlight(true)

        --- TODO: fix hl.
        local function update_hl()
          -- Greying out the search area
          vim.api.nvim_set_hl(0, 'LeapBackdrop', { link = 'Comment' })
          -- -- lightspeed like hl
          -- vim.api.nvim_set_hl(0, 'LeapMatch', {
          --   fg = colors.leap_match_fg,
          --   bold = true,
          --   italic = true,
          --   undercurl = false,
          --   underline = true,
          -- })
          -- vim.api.nvim_set_hl(0, 'LeapLabelPrimary', {
          --   bg = colors.leap_label_primary_bg,
          --   fg = colors.leap_label_primary_fg,
          --   bold = false,
          -- })
          -- vim.api.nvim_set_hl(0, 'LeapLabelSecondary', {
          --   bg = colors.leap_label_secondary,
          --   fg = '#ffffff',
          --   bold = true,
          --   undercurl = true,
          --   underline = false,
          -- })
        end

        au.register_event(au.events.AfterColorschemeChanged, {
          name = 'update_leap_hl',
          immediate = true,
          callback = function()
            update_hl()
          end,
        })
      end,
    },
  },
  {
    'chentoast/marks.nvim',
    event = au.user_autocmds.FileOpenedAfter_User,
    config = function()
      require('marks').setup({
        default_mappings = false,
        builtin_marks = {},
        refresh_interval = 600,
        excluded_filetypes = { 'oil', 'expJABS', 'NvimTree' },
        -- keymaps for marks.
        mappings = {
          preview = 'm:',
          toggle = 'm<space>',
          next = 'm,',
          prev = 'm.',
          delete_buf = 'm<bs>',
        },
      })

      -- sync hl.
      -- local au = require('libs.runtime.au')
      au.register_event(au.events.AfterColorschemeChanged, {
        name = "update_marks_hl",
        immediate = true,
        callback = function()
          vim.api.nvim_set_hl(0, 'MarkSignHL', {
            bg = 'red',
            fg = '#ffffff',
            bold = true,
            italic = true,
          })
        end,
      })
    end,
  },

  {
    'echasnovski/mini.ai',
    event = au.user_autocmds.FileOpenedAfter_User,
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }, {}),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }, {}),
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }, {}),
        },
      }
    end,
    config = function(_, opts)
      require("mini.ai").setup(opts)
      -- register all text objects with which-key
      if require("libs.runtime.utils").has_plugin("which-key.nvim") then
        ---@type table<string, string|table>
        local i = {
          [" "] = "Whitespace",
          ['"'] = 'Balanced "',
          ["'"] = "Balanced '",
          ["`"] = "Balanced `",
          ["("] = "Balanced (",
          [")"] = "Balanced ) including white-space",
          [">"] = "Balanced > including white-space",
          ["<lt>"] = "Balanced <",
          ["]"] = "Balanced ] including white-space",
          ["["] = "Balanced [",
          ["}"] = "Balanced } including white-space",
          ["{"] = "Balanced {",
          ["?"] = "User Prompt",
          _ = "Underscore",
          a = "Argument",
          b = "Balanced ), ], }",
          c = "Class",
          f = "Function",
          o = "Block, conditional, loop",
          q = "Quote `, \", '",
          t = "Tag",
        }
        local a = vim.deepcopy(i)
        for k, v in pairs(a) do
          a[k] = v:gsub(" including.*", "")
        end

        local ic = vim.deepcopy(i)
        local ac = vim.deepcopy(a)
        for key, name in pairs({ n = "Next", l = "Last" }) do
          i[key] = vim.tbl_extend("force", { name = "Inside " .. name .. " textobject" }, ic)
          a[key] = vim.tbl_extend("force", { name = "Around " .. name .. " textobject" }, ac)
        end
        require("which-key").register({
          mode = { "o", "x" },
          i = i,
          a = a,
        })
      end
    end,
  },

  {
    {
      "roobert/surround-ui.nvim",
      dependencies = {
        "kylechui/nvim-surround",
        "folke/which-key.nvim",
      },
      config = function()
        require("surround-ui").setup({
          root_key = "S"
        })
      end,
    },
    {
      'kylechui/nvim-surround',
      version = "*",
      event = au.user_autocmds.FileOpened_User,
      opts = {
        keymaps = {
          delete = 'dz',
        },
      },
      dependencies = {
        'roobert/surround-ui.nvim',
      }
    },
  },

  {
    -- https://github.com/Wansmer/treesj
    'Wansmer/treesj',
    keys = {
      {
        '<leader>mjt',
        '<cmd>lua require("treesj").toggle()<cr>',
        desc = 'Toggle',
      },
      {
        '<leader>mjs',
        '<cmd>lua require("treesj").split()<cr>',
        desc = 'Split',
      },
      {
        '<leader>mjj',
        '<cmd>lua require("treesj").join()<cr>',
        desc = 'Join',
      },
    },
    dependencies = { 'nvim-treesitter/nvim-treesitter' },
    opts = {
      use_default_keymaps = false,
    }
  },
  ---prevent the cursor from moving when using shift and filter actions.
  { 'gbprod/stay-in-place.nvim', config = true, event = au.user_autocmds.FileOpenedAfter_User },

  {
    -- https://github.com/mg979/vim-visual-multi/wiki/Quick-start
    'mg979/vim-visual-multi',
    enabled = function() return false end,
    keys = { { 'v', 'V' } },
    config = function() vim.g.VM_leader = '<space>' end,
  },

  {
    'folke/flash.nvim',
    enabled = enable_flash,
    keys = {
      ';',
      ',',
      'f',
      'F',
      't',
      'T',
      {
        "<CR>",
        mode = { "n" },
        function()
          require("flash").jump({
            search = {
              forward = true,
            }
          })
        end,
      },
      {
        "<S-CR>",
        mode = { 'n' },
        function()
          require("flash").jump({
            search = {
              forward = false,
            }
          })
        end,
      },
    },
    opts = {
      search = {
        forward = false,
      }
    },
    config = function(_, opts)
      require('flash').setup(opts)
    end
  }
})
