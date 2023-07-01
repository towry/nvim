vim.filetype.add({
  extension = {
  },
  filename = {
    ['.envrc'] = 'bash',
    ['Brewfile'] = 'brewfile',
  },
  pattern = {
    ['.*ignore$'] = "gitignore",
    ['.es6$'] = "javascript",
    ['.code-snippets'] = 'json',
    ['.handlebars'] = 'html'
  }
})
