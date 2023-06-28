return function(opts)
  opts = vim.tbl_extend('force', {}, opts or {})
  opts.cwd = opts.cwd or require('libs.runtime.utils').get_root()
  local prompt_title = table.concat({
    '-F(literal)',
    '-g(glob)',
    '-e(reg)',
    '-t/T(type filter)',
    '-S(smart case)',
    '--no-[filename|ignore|ignore-dot|ignore-exclude]'
  }, ' ')
  opts.results_title = opts.results_title or require('libs.runtime.path').home_to_tilde(opts.cwd)
  opts.prompt_title = opts.prompt_title or prompt_title
  return require('telescope').extensions.live_grep_args.live_grep_args(opts)
end