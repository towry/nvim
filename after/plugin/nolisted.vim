" prevent from show in bpre,bnext
augroup nolisted_fts
    autocmd!
    " do not set gitcommit, otherwise commit not working
    autocmd FileType qf,GV set nobuflisted
augroup END
