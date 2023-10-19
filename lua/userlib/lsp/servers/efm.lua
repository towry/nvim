local efm_setup_done = false


return function(opts)
    -- setup efmls if not done already
    if not efm_setup_done then
      efm_setup_done = true
      require('lspconfig').efm.setup(require('userlib.lsp.filetypes').efmls_config(opts.capabilities))
    end
end