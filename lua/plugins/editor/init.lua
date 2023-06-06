return {
  {
    import = "plugins.editor.essential",
    init = function()
      -- to override the defaults config
      -- call below in the userland entry point before loading plugins with your
      -- customized configurations.
      require('libs.cfg').setup({})
    end,
  },
  {
    import = "plugins.editor.lang"
  },
  {
    import = "plugins.editor.lsp"
  },
  {
    import = "plugins.editor.motion",
  },
  {
    import = "plugins.editor.indent",
  },
  {
    import = "plugins.editor.folding",
  },
  {
    import = "plugins.editor.readbility",
  }
}
