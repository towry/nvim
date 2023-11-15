vim.filetype.add({
  extension = {
    ['es6'] = 'javascript',
    ['code-snippets'] = 'json',
    ['handlebars'] = 'htmldjango',
    ['tigrc'] = 'bash',
    ['tmux'] = 'bash',
  },
  filename = {
    ['.envrc'] = 'bash',
    ['Brewfile'] = 'brewfile',
    ['config'] = 'bash',
    ['.swcrc'] = 'json',
  },
  pattern = {
    ['.*ignore$'] = 'gitignore',
  },
})
