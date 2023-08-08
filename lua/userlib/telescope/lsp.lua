local utils = require('userlib.runtime.utils')
local M = {}

function M.lsp_definitions()
  utils.use_plugin('telescope.builtin', function(builtins)
    builtins.lsp_definitions {
      layout_strategy = "vertical",
      layout_config = {
        prompt_position = "top",
      },
      sorting_strategy = "ascending",
      ignore_filename = false,
    }
  end, function()
    vim.lsp.buf.definition()
  end)
end

function M.lsp_references()
  utils.use_plugin('telescope.builtin', function(builtins)
    builtins.lsp_references {
      layout_strategy = "vertical",
      layout_config = {
        prompt_position = "top",
      },
      sorting_strategy = "ascending",
      ignore_filename = false,
    }
  end, function()
    vim.lsp.buf.references()
  end)
end

function M.lsp_implementations()
  utils.use_plugin("telescope.builtin", function(builtins)
    builtins.lsp_implementations {
      layout_strategy = "vertical",
      layout_config = {
        prompt_position = "top",
      },
      sorting_strategy = "ascending",
      ignore_filename = false,
    }
  end, function()
    vim.lsp.buf.implementation()
  end)
end

return M
