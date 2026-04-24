if (exists('g:loaded_magic_link_paste') && g:loaded_magic_link_paste) || &compatible
    finish
endif

let s:filetypes = get(g:, 'magic_link_paste_filetypes', ['markdown'])

augroup magic_link_paste
    autocmd!
    if index(s:filetypes, 'markdown') >= 0
      autocmd FileType markdown
        \ xnoremap <buffer> p <Cmd>call magic_link_paste#markdown#paste()<CR>
    endif
augroup END

if has('nvim') && get(g:, 'magic_link_paste_intercept_bracketed_paste', 1)
  call v:lua.require'magic_link_paste'.setup_paste_override(s:filetypes)
endif

let g:loaded_magic_link_paste = 1
