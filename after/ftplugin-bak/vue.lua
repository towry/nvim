-- make gf work better.
vim.cmd([[setlocal suffixesadd+=.js,.ts,.scss,tsx,.jsx,.vue,.html]])
vim.cmd('setlocal path+=src')
vim.opt_local.commentstring = [[<!--%s-->]]
vim.opt_local.includeexpr = "substitute(v:fname,'@','src','g')"

require('user.ftplugins.css').attach({
  ft = 'vue',
})
