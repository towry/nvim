-- https://github.com/leaxoy/v/blob/37d8558dde2117b7c188f4e2687d892dbcff7b53/lua/lsp/init.lua
-- not working.
function OrganizeImports()
  vim.lsp.buf.code_action({ context = { only = { 'source.organizeImports' } }, apply = true })
end

return {
  OrganizeImports = {
    function()
      OrganizeImports()
    end,
    description = 'Organize imports',
  },
}
