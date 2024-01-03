local utils = require('userlib.runtime.utils')
local M = {}

local use_fzf = true

function M.lsp_definitions()
  utils.use_plugin(use_fzf and 'fzf-lua' or 'telescope.builtin', function(builtins)
    if use_fzf then
      builtins.lsp_definitions({
        fullscreen = false,
        reuse_win = true,
      })
    else
      builtins.lsp_definitions({
        layout_strategy = 'vertical',
        layout_config = {
          prompt_position = 'top',
        },
        sorting_strategy = 'ascending',
        ignore_filename = false,
      })
    end
  end, function()
    vim.lsp.buf.definition()
  end)
end

function M.lsp_references()
  utils.use_plugin(use_fzf and 'fzf-lua' or 'telescope.builtin', function(builtins)
    if use_fzf then
      builtins.lsp_references({
        fullscreen = false,
        include_current_line = true,
        reuse_win = true,
      })
    else
      builtins.lsp_references({
        layout_strategy = 'vertical',
        layout_config = {
          prompt_position = 'top',
        },
        sorting_strategy = 'ascending',
        ignore_filename = false,
      })
    end
  end, function()
    vim.lsp.buf.references()
  end)
end

function M.lsp_implementations()
  utils.use_plugin(use_fzf and 'fzf-lua' or 'telescope.builtin', function(builtins)
    if use_fzf then
      builtins.lsp_implementations({
        fullscreen = false,
        reuse_win = true,
      })
    else
      builtins.lsp_implementations({
        layout_strategy = 'vertical',
        layout_config = {
          prompt_position = 'top',
        },
        sorting_strategy = 'ascending',
        ignore_filename = false,
      })
    end
  end, function()
    vim.lsp.buf.implementation()
  end)
end

-- TODO: lsp_finder
return M
