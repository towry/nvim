" prevent from show in bpre,bnext
augroup nolisted_fts
    autocmd!
    autocmd FileType qf,GV set nobuflisted
augroup END
