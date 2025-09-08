if (exists('g:loaded_magic_link_paste') && g:loaded_magic_link_paste) || &compatible
    finish
endif

let s:filetypes = get(g:, 'magic_link_paste_filetypes', ['markdown'])

augroup magic_link_paste
    autocmd!
    if index(s:filetypes, 'markdown') >= 0
      autocmd FileType markdown
        \ xnoremap <buffer> <expr> p magic_link_paste#markdown#paste()
    endif
augroup END

let g:loaded_magic_link_paste = 1
