return {
  {
    ':ToggleSpider',
    description = 'Toggle spider motion',
  },
  -- copilot
  {
    ':Copilot enable',
    description = 'Enable github copilot',
  },
  {
    ':h user-notes',
    description = 'View user-notes',
  },
  {
    ':helptags doc',
    description = 'Make doc helptags',
  },
  {
    ':Copilot disable',
    description = 'Disable github copilot',
  },
  -- switch
  {
    ':Switch',
    description = 'Switch variable, e.g: {true <-> false}',
  },
  -- markdown
  {
    ':MarkdownPreview',
    description = 'Start markdown preview',
  },
  {
    ':MarkdownPreviewStop',
    description = 'Stop markdown preview',
  },
  {
    ':Cheat',
    description = 'Open cheat.sh',
  },
  {
    ':Cheatsheet',
    description = 'Open cheatsheet',
  },
  ----------------------------------
  ---https://github.com/mrjones2014/dotfiles/blob/master/nvim/lua/my/legendary/commands.lua
  {
    ':CargoToml',
    function()
      vim.lsp.buf_request(
        0,
        'experimental/openCargoToml',
        { textDocument = vim.lsp.util.make_text_document_params(0) },
        function(...)
          ---@diagnostic disable-next-line
          local path = vim.tbl_get({ ... }, 2, 'uri')
          if path and #path > 0 then
            if vim.startswith(path, 'file://') then
              path = path:sub(#'file://')
            end
            vim.cmd.e(path)
          end
        end
      )
    end,
    desc = 'Open the `Cargo.toml` that is closest to the current file in the tree',
  },
}
