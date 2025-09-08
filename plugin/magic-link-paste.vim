if (exists('g:loaded_magic_link_paste') && g:loaded_magic_link_paste) || &compatible
    finish
endif

let s:filetypes = get(g:, 'magic_link_paste_filetypes', ['markdown'])

augroup magic_link_paste
    autocmd!
    if index(s:filetypes, 'markdown') >= 0
      autocmd FileType markdown
        \ xmap <buffer> <expr> p markdown_magic_link_paste#visual_expr_mapping()
    endif
augroup END

let g:loaded_magic_link_paste = 1
