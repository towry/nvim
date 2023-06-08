return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    opts = {
      panel = {
        enabled = true,
      },
      suggestion = {
        enabled = true,
      }
    },
    config = function(_, opts)
      require("copilot").setup(opts)
    end,
  },

  {
    "zbirenbaum/copilot-cmp",
    dependencies = {
      {
        'zbirenbaum/copilot.lua',
        opts = {
          panel = {
            enabled = false,
          },
          suggestion = {
            enabled = false,
          }
        }
      }
    },
    config = function()
      require("copilot_cmp").setup()
    end
  }
}
