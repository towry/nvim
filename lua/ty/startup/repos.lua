local config = require('ty.core.config')
local initd = require('ty.startup.initd.plugins')
local _ = require('ty.startup.utils').load_modules_packages

return _({
  common = {
    {
      'nvim-lua/plenary.nvim',
    },
    {
      'nvim-tree/nvim-web-devicons',
    },
    {
      'nvim-telescope/telescope.nvim',
      pin = true,
      -- commit = '7141515a7cabde464',
      cmd = { 'Telescope' },
      dependencies = {
        { 'nvim-lua/popup.nvim' },
        { 'nvim-lua/plenary.nvim' },
        { 'ThePrimeagen/git-worktree.nvim' },
        { 'nvim-telescope/telescope-live-grep-args.nvim' },
        {
          'nvim-telescope/telescope-fzf-native.nvim',
          build = 'make',
        },
        {
          'tknightz/telescope-termfinder.nvim',
        },
      },
      ImportConfig = 'telescope',
    },
    {
      'echasnovski/mini.nvim',
      event = { 'BufReadPre', 'BufNewFile' },
      ImportConfig = 'mini',
      ImportInit = 'mini',
    },
    {
      -- If you've ever tried using the . command after a plugin map,
      -- you were likely disappointed to discover it only repeated the last native command inside that map, rather than the map as a whole.
      'tpope/vim-repeat',
      keys = { '.' },
    },
  },
  keymaps = {
    {
      -- free the leader key.
      -- 'anuvyklack/hydra.nvim',
      'pze/hydra.nvim',
    },
    {
      'folke/which-key.nvim',
      lazy = true,
      pin = true,
      ImportConfig = 'whichkey',
    },
    {
      'mrjones2014/legendary.nvim',
      pin = true,
      dependencies = {
        -- used for frecency sort
        'kkharji/sqlite.lua',
      },
      ImportConfig = 'legendary',
    },
  },
  autocmp = {
    {
      'L3MON4D3/LuaSnip',
      lazy = true,
      dependencies = { 'rafamadriz/friendly-snippets', 'saadparwaiz1/cmp_luasnip' },
    },
    {
      'hrsh7th/nvim-cmp',
      event = { 'InsertEnter', 'CmdlineEnter' },
      Feature = 'autocomplete',
      dependencies = {
        'hrsh7th/cmp-nvim-lsp-signature-help',
        'onsails/lspkind-nvim',
        'hrsh7th/cmp-nvim-lua',
        'hrsh7th/cmp-nvim-lsp',
        'hrsh7th/cmp-buffer',
        'hrsh7th/cmp-path',
        'hrsh7th/cmp-cmdline',
        'hrsh7th/cmp-calc',
        {
          'tzachar/cmp-tabnine',
          build = './install.sh',
        },
        'David-Kunz/cmp-npm',
        'saadparwaiz1/cmp_luasnip',
      },
      config = function() require('ty.contrib.autocmp.cmp_rc').setup_cmp() end,
    },
    {
      'pze/codeium.nvim',
      cmd = 'Codeium',
      dev = false,
      enabled = false,
      dependencies = {
        'nvim-lua/plenary.nvim',
        'MunifTanjim/nui.nvim',
      },
      config = true,
    },
    {
      'windwp/nvim-autopairs',
      event = { 'InsertEnter' },
      Feature = 'autocomplete',
      config = function() require('ty.contrib.autocmp.autopairs_rc').setup() end,
    },
    {
      -- https://github.com/dermoumi/dotfiles/blob/418de1a521e4f4ac6dc0aa10e75ffb890b0cb908/nvim/lua/plugins/copilot.lua#L4
      'github/copilot.vim',
      event = { 'InsertEnter' },
      keys = { { '<C-/>', mode = 'i' } },
      cmd = { 'Copilot' },
      config = function()
        -- <C-/>
        vim.keymap.set({ 'i' }, '<C-/>', 'copilot#Suggest()', {
          silent = true,
          expr = true,
          script = true,
        })
      end,
      ImportInit = 'copilot',
    },
  },
  buffer = {
    {
      's1n7ax/nvim-window-picker',
      pin = true,
      ImportOption = 'window_picker',
    },
    {
      'kwkarlwang/bufresize.nvim',
      config = true,
    },
    {
      'mrjones2014/smart-splits.nvim',
      -- keys = { '<C-j>', '<C-h>', '<C-k>', '<C-l>', '<A-j>', '<A-h>', '<A-k>', '<A-l>' },
      dependencies = {
        'kwkarlwang/bufresize.nvim',
      },
      build = "./kitty/install-kittens.bash",
      ImportConfig = 'smart_splits',
    },
    {
      'axkirillov/hbac.nvim',
      event = "VeryLazy",
      config = function()
        require('hbac').setup({
          autoclose = true,
          threshold = 5,
          close_buffers_with_windows = false,
        })
      end,
    }
  },
  debugger = {
    {
      -- https://github.com/stevearc/overseer.nvim
      -- TODO: finish.
      'stevearc/overseer.nvim',
      cmd = { 'OverseerRun', 'OverseerToggle' },
      config = true,
    },
    {
      'mfussenegger/nvim-dap',
      dependencies = {
        { 'theHamsta/nvim-dap-virtual-text' },
        { 'rcarriga/nvim-dap-ui' },
      },
      ImportConfig = 'dap',
    },
    {
      'rcarriga/neotest',
      dependencies = {
        'nvim-lua/plenary.nvim',
        'nvim-treesitter/nvim-treesitter',
        'haydenmeade/neotest-jest',
      },
      ImportConfig = 'neotest',
    },
  },
  editing = {
    {
      'williamboman/mason.nvim',
      ImportOption = 'mason',
    },

    {
      'neovim/nvim-lspconfig',
      name = 'lsp',
      event = { 'BufReadPre', 'BufNewFile' },
      dependencies = {
        'jose-elias-alvarez/typescript.nvim',
        'hrsh7th/cmp-nvim-lsp',
        'jose-elias-alvarez/null-ls.nvim',
        'williamboman/mason-lspconfig.nvim',
        'j-hui/fidget.nvim',
      },
      Feature = 'lsp',
      ImportConfig = 'lspconfig',
      ImportInit = 'lspconfig',
    },

    {
      'lukas-reineke/lsp-format.nvim',
      Feature = 'lsp',
      ImportConfig = 'lsp_format',
    },

    {
      'nvimdev/lspsaga.nvim',
      cmd = { 'Lspsaga', },
      dependencies = {
        --Please make sure you install markdown and markdown_inline parser
        { 'nvim-treesitter/nvim-treesitter' },
      },
      ImportConfig = 'lspsaga',
    },

    {
      'folke/neodev.nvim',
    },

    {
      'lvimuser/lsp-inlayhints.nvim',
      branch = "anticonceal",
      event = 'LspAttach',
      config = true,
    },

    {
      'kevinhwang91/nvim-ufo',
      event = 'LspAttach',
      dependencies = {
        'kevinhwang91/promise-async',
      },
      ImportConfig = 'nvim_ufo',
    },

    {
      'dhruvasagar/vim-table-mode',
    },

    {
      'numToStr/Comment.nvim',
      event = { 'BufReadPost', 'BufNewFile' },
      dependencies = { 'JoosepAlviste/nvim-ts-context-commentstring' },
      ImportConfig = 'comment',
    },

    {
      'bennypowers/splitjoin.nvim',
      keys = {
        { 'gj', function() require 'splitjoin'.join() end,  desc = 'Join the object under cursor' },
        { 'g,', function() require 'splitjoin'.split() end, desc = 'Split the object under cursor' },
      }
    },

    {
      -- https://github.com/mg979/vim-visual-multi/wiki/Quick-start
      'mg979/vim-visual-multi',
      enabled = function() return config.editing.visual_multi_cursor end,
      event = 'BufReadPost',
      config = function() vim.g.VM_leader = ';' end,
    },
    {
      -- easily switch variables, true <=> false
      'AndrewRadev/switch.vim',
      cmd = 'Switch',
      ImportConfig = 'switch',
    },
    {
      -- better yank.
      'gbprod/yanky.nvim',
      event = { 'BufReadPost', 'BufNewFile' },
      ImportConfig = 'yanky',
    },
  },
  editor = {
    {
      'Pocco81/true-zen.nvim',
      cmd = { 'TZNarrow', 'TZFocus', 'TZMinimalist', 'TZAtaraxis' },
      ImportOption = 'true_zen',
    },

    {
      'folke/todo-comments.nvim',
      event = { 'BufReadPost', 'BufNewFile' },
      ImportConfig = 'todo_comments',
    },

    {
      -- Whenever cursor jumps some distance or moves between windows, it will flash so you can see where it is.
      'DanilaMihailov/beacon.nvim',
      cmd = { 'Beacon' },
      init = function()
        vim.g.beacon_ignore_buffers = { 'quickfix' }
        vim.g.beacon_ignore_filetypes = {
          'alpha',
          'lazy',
          'TelescopePrompt',
          'term',
          'nofile',
          'spectre_panel',
          'help',
          'txt',
          'log',
          'Trouble',
          'NvimTree',
          'qf',
        }
        vim.g.beacon_size = 60
      end,
      ImportConfig = 'cursor_beacon',
    },

    {
      'luukvbaal/statuscol.nvim',
      event = { 'BufReadPost', 'BufNewFile' },
      cond = function() return vim.fn.has('nvim-0.9.0') == 1 end,
      ImportConfig = 'statuscol',
    },

    {
      'lukas-reineke/indent-blankline.nvim',
      event = 'BufReadPost',
      ImportConfig = 'indent_line',
    },
    {
      -- Blazing fast indentation style detection, I guess :)
      'NMAC427/guess-indent.nvim',
      event = 'InsertEnter',
      cmd = { 'GuessIndent' },
      ImportOption = 'guess_indent',
    },
    {
      'winston0410/range-highlight.nvim',
      dependencies = { 'winston0410/cmd-parser.nvim' },
      event = 'CmdLineEnter',
      config = true,
    },
    {
      'nacro90/numb.nvim',
      event = 'CmdLineEnter',
      config = true,
    },
    {
      'goolord/alpha-nvim',
      cmd = { 'Alpha' },
      ImportConfig = 'dashboard',
    },
    {
      'ahmedkhalf/project.nvim',
      name = 'project_nvim',
      event = { 'VeryLazy' },
      ImportOption = 'rooter',
    },
    {
      'Shatur/neovim-session-manager',
      cmd = { 'SessionManager' },
      ImportConfig = 'session_manager',
      Feature = 'session',
    },
    {
      'ethanholz/nvim-lastplace',
      event = { 'BufReadPre', 'BufNewFile' },
      ImportOption = 'buf_lastplace',
    },
  },
  explorer = {
    {
      'kyazdani42/nvim-tree.lua',
      cmd = {
        'NvimTreeToggle',
        'NvimTreeFindFileToggle',
        'NvimTreeFindFile',
      },
      ImportConfig = 'nvim_tree',
    },

    {
      'simrat39/symbols-outline.nvim',
      cmd = { 'SymbolsOutline', 'SymbolsOutlineOpen', 'SymbolsOutlineClose' },
      ImportOption = 'outline',
    },

    {
      'folke/trouble.nvim',
      cmd = { 'TroubleToggle', 'Trouble' },
      ImportConfig = 'trouble',
    },

    {
      'nvim-pack/nvim-spectre',
      ImportOption = 'search_spectre',
    },

    {
      -- https://github.com/kevinhwang91/nvim-bqf
      'kevinhwang91/nvim-bqf',
      ft = 'qf',
      dependencies = {
        { 'junegunn/fzf', build = function() vim.fn['fzf#install']() end },
      },
    },

    {
      'ThePrimeagen/harpoon',
    },

    {
      "imNel/monorepo.nvim",
      ImportOption = "monorepo"
    }
  },
  git = {
    { 'kdheepak/lazygit.nvim', cmd = 'LazyGit' },
    {
      'tpope/vim-fugitive',
      cmd = {
        'G',
        'Git',
        'Gread',
        'Gwrite',
        'Ggrep',
        'GMove',
        'GDelete',
        'GBrowse',
        'Gdiffsplit',
        'Gvdiffsplit',
        'Gedit',
        'Gsplit',
      },
    },
    {
      --
      'shumphrey/fugitive-gitlab.vim',
      dependencies = {
        'tpope/vim-fugitive',
      },
    },
    {
      -- git runtimes. ft etc.
      'tpope/vim-git',
      event = { 'BufReadPost', 'BufNewFile' },
      cond = function() return true end,
    },
    {
      -- tig like git commit browser.
      'junegunn/gv.vim',
      cmd = { 'GV' },
      dependencies = {
        'tpope/vim-fugitive',
      },
    },
    {
      'lewis6991/gitsigns.nvim',
      event = { 'BufReadPost', 'BufNewFile' },
      ImportConfig = 'gitsigns',
    },
    {
      'sindrets/diffview.nvim',
      cmd = {
        'DiffviewLog',
        'DiffviewOpen',
        'DiffviewClose',
        'DiffviewRefresh',
        'DiffviewFocusFile',
        'DiffviewFileHistory',
        'DiffviewToggleFiles',
      },
      ImportConfig = 'diffview',
    },
    {
      'akinsho/git-conflict.nvim',
      tag = 'v1.0.0',
      cmd = {
        'GitConflictChooseBoth',
        'GitConflictNextConflict',
        'GitConflictChooseOurs',
        'GitConflictPrevConflict',
        'GitConflictChooseTheirs',
        'GitConflictListQf',
        'GitConflictChooseNone',
        'GitConflictRefresh',
      },
      ImportConfig = 'git_conflict',
    },
    {
      'ThePrimeagen/git-worktree.nvim',
      ImportConfig = 'git_worktree',
    },
  },
  langsupport = {
    {
      'nvim-treesitter/nvim-treesitter',
      event = { 'BufReadPre', 'BufNewFile' },
      build = function()
        if #vim.api.nvim_list_uis() == 0 then
          -- update sync if running headless
          vim.cmd.TSUpdateSync()
        else
          -- otherwise update async
          vim.cmd.TSUpdate()
        end
      end,
      dependencies = {
        'yioneko/nvim-yati',
        'nvim-treesitter/nvim-treesitter-textobjects',
        'RRethy/nvim-treesitter-textsubjects',
        'nvim-treesitter/nvim-treesitter-refactor',
        'JoosepAlviste/nvim-ts-context-commentstring',
        -- 'kiyoon/treesitter-indent-object.nvim',
      },
      ImportConfig = 'treesitter',
    },
    {
      'iamcco/markdown-preview.nvim',
      build = 'cd app && npm install',
      init = function() vim.g.mkdp_filetypes = { 'markdown' } end,
      ft = { 'markdown' },
    },
    {
      'vuki656/package-info.nvim',
      event = 'BufEnter package.json',
      ImportConfig = 'package_info',
    },
    {
      'danymat/neogen',
      cmd = 'Neogen',
      dependencies = { 'nvim-treesitter/nvim-treesitter' },
      config = true,
    },
    {
      'NvChad/nvim-colorizer.lua',
      ft = config.langsupport.colorizer.filetypes,
      ImportOption = 'colorizer',
      Feature = 'colorizer',
    },
    {
      'm-demare/hlargs.nvim',
      event = 'BufReadPost',
      ImportOption = 'hlargs',
    },
    {
      'mrjones2014/lua-gf.nvim',
      ft = 'lua'
    },
    {
      'simrat39/rust-tools.nvim',
      ft = { 'rust', 'toml' },
      ImportConfig = "rust",
    }
  },
  navigate = {
    {
      'hrsh7th/nvim-gtd',
      config = true,
    },
    {
      -- https://github.com/jinh0/eyeliner.nvim
      'jinh0/eyeliner.nvim',
      ImportConfig = 'eyeliner',
      keys = { { 'f' }, { 'F' }, { 't' }, { 'T' } },
    },
    {
      'ggandor/leap.nvim',
      dependencies = {
        'tpope/vim-repeat',
      },
      keys = { { 's' }, { 'S' }, { 'gs' }, { 'f' }, { 'F' }, { 'vs' }, { 'ds' } },
      ImportConfig = 'leap',
    },
    {
      'declancm/cinnamon.nvim',
      -- broken after upgraded neovim.
      enabled = false,
      event = { 'BufReadPost', 'BufNewFile' },
    },
    {
      'cbochs/portal.nvim',
      cmd = { 'Portal' },
      dependencies = {
        'cbochs/grapple.nvim',
      },
      ImportConfig = 'portal',
    },
    {
      'cbochs/grapple.nvim',
      cmd = { 'GrappleToggle', 'GrapplePopup', 'GrappleCycle' },
      ImportOption = 'grapple',
    },
    {
      'chentoast/marks.nvim',
      event = 'BufReadPost',
      ImportConfig = 'marks',
    },
    {
      -- jump html tags.
      'harrisoncramer/jump-tag',
      dependencies = {
        'nvim-treesitter/nvim-treesitter',
      },
    },
    { 'gbprod/stay-in-place.nvim', config = true, event = 'BufReadPost' },
    {
      'kylechui/nvim-surround',
      event = 'BufReadPost',
      ImportOption = 'surround',
    },
  },
  statusline = {
    {
      'nvim-lualine/lualine.nvim',
      dependencies = {
        {
          'pze/lualine-copilot',
          dev = false,
        },
      },
      event = { 'BufReadPost', 'BufNewFile' },
      ImportConfig = 'lualine',
    },
    {
      'b0o/incline.nvim',
      event = { 'BufReadPost', 'BufNewFile' },
      ImportConfig = 'incline',
      enabled = false,
    },
  },
  term = {
    {
      'willothy/flatten.nvim',
      enabled = false,
      ImportOption = 'term_flatten',
    },
    {
      'akinsho/nvim-toggleterm.lua',
      cmd = { 'ToggleTerm', 'TermExec' },
      branch = 'main',
      tag = 'v2.2.1',
      ImportInit = 'toggleterm',
      ImportConfig = 'toggleterm',
    },
  },
  tools = {
    {
      'pze/cheatsheet.nvim',
      dev = false,
      dependencies = {
        'nvim-lua/popup.nvim',
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
      },
      cmd = 'Cheatsheet',
      ImportOption = 'cheatsheet',
    },
    {
      enabled = false,
      'michaelb/vim-tips',
      init = function() vim.g.vim_tips_display_at_startup = 0 end,
    },
    {
      'RishabhRD/nvim-cheat.sh',
      cmd = { 'Cheat', 'CheatWithoutComments', 'CheatList', 'CheatListWithoutComments' },
      dependencies = {
        'RishabhRD/popfix',
      },
      init = function() vim.g.cheat_default_window_layout = 'vertical_split' end,
    },
    {
      'pze/ChatGPT.nvim',
      cmd = { 'ChatGPT', 'ChatGPTActAs' },
      dependencies = {
        'MunifTanjim/nui.nvim',
        'nvim-lua/plenary.nvim',
        'nvim-telescope/telescope.nvim',
      },
      enabled = function()
        -- create OPENAI_API_KEY in `$HOME/.dotfiles/source/private.sh`
        return os.getenv('OPENAI_API_KEY') ~= nil
      end,
      ImportOption = 'chat_gpt',
    },
    {
      'dstein64/vim-startuptime',
      cond = function()
        return vim.env.PROFILE == 1
      end,
      lazy = false,
    },
    {
      'alanfortlink/blackjack.nvim',
    },
    {
      'nvim-colortils/colortils.nvim',
      cmd = 'Colortils',
      config = true
    },
    {
      'keaising/im-select.nvim',
      event = "VeryLazy",
      enabled = function()
        return vim.fn.executable('im-select')
      end,
      ImportConfig = "im_select",
    }
  },
  ui = {
    {
      'ellisonleao/gruvbox.nvim',
      enabled = false,
      -- make sure we load this during startup if it is your main colorscheme
      lazy = true,
      -- make sure to load this before all the other start plugins
      priority = 1000,
      ImportConfig = 'gruvbox',
    },
    {
      'sainnhe/everforest',
      lazy = false,
      priority = 1000,
      ImportInit = 'everforest',
    },
    { 'nvim-lua/popup.nvim' },
    {
      'MunifTanjim/nui.nvim',
    },
    {
      'stevearc/dressing.nvim',
      ImportInit = 'dressing',
      ImportConfig = 'dressing',
    },
    {
      'rcarriga/nvim-notify',
      ImportInit = 'notify',
      ImportConfig = 'notify',
    },
    {
      'tummetott/reticle.nvim',
      event = { 'BufReadPost', 'BufNewFile' },
      ImportOption = 'reticle',
    }
  },
}, initd)
