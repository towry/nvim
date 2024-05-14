" prevent from show in bpre,bnext
augroup nolisted_fts
    autocmd!
    autocmd FileType qf,GV,gitcommit set nobuflisted
augroup END
