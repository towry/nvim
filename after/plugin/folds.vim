
" Move to start of fold
nnoremap <leader>zs zo[z

" Move to end of fold
nnoremap <leader>ze zo]z


function! SuperFoldToggle()
    " Force the fold on the current line to immediately open or close.  Unlike za
    " and zo it only takes one application to open any fold.  Unlike zO it does
    " not open recursively, it only opens the current fold.
    if foldclosed('.') == -1
        silent! foldclose
    else
        while foldclosed('.') != -1
            silent! foldopen
        endwhile
    endif
endfunction

nnoremap <silent> <space>zt <CMD>call SuperFoldToggle()<CR>

