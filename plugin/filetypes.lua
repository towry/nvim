--- if buffer is not saved on disk, this will not work.
vim.filetype.add({
  extension = {
    ['es6'] = 'javascript',
    ['code-snippets'] = 'json',
    ['handlebars'] = 'htmldjango',
    ['tigrc'] = 'bash',
    ['tmux'] = 'bash',
    ['mdx'] = 'mdx',
  },
  filename = {
    ['.envrc'] = 'bash',
    ['Brewfile'] = 'brewfile',
    ['config'] = 'bash',
    ['.swcrc'] = 'json',
  },
  pattern = {
    ['.*ignore'] = 'gitignore',
    ['.*justfile'] = { 'just', 'make' },
  },
})
