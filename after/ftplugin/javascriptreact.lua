-- make gf work better.
vim.cmd([[setlocal suffixesadd+=.js,.ts,.scss,tsx,.jsx,.vue]])
vim.cmd('setlocal path+=src')

require('user.ftplugins.javascript').attach()
