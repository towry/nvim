--- You can use v:count to search inside folder relative to current buf.
return function(opts)
  opts = vim.tbl_extend('force', {}, opts or {})
  opts.cwd = opts.cwd or require('userlib.telescope.helpers').get_cwd_relative_to_buf(0, vim.v.count)
  local prompt_title = table.concat({
    '-F(literal)',
    '-g(glob)',
    '-e(reg)',
    '-t/T(type filter)',
    '-S(smart case)',
    '--no-[filename|ignore|ignore-dot|ignore-exclude]'
  }, ' ')
  opts.results_title = opts.results_title or require('userlib.runtime.path').home_to_tilde(opts.cwd)
  opts.prompt_title = opts.prompt_title or prompt_title
  return require('telescope').extensions.live_grep_args.live_grep_args(opts)
end
