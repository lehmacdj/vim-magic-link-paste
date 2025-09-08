xnoremap <Plug>(magic_link_paste-markdown) <Esc>:<C-U>call magic_link_paste#markdown#paste()<CR>

" Emulates the behavior of apps like slack where pasting a link over a
" selection turns the selection into a link.
"
" Intended to be mapped like so for filetypes that use markdown link syntax:
" xnoremap <buffer> p :<C-u>call magic_link_paste#markdown#paste()<CR>
" This is done automatically for the markdown filetype by the plugin unless
" disabled.
function! magic_link_paste#markdown#paste() abort
  let l:reg = get(v:, 'register', '"')
  let l:to_paste = getreg(l:reg)
  let l:pasting_link = l:to_paste =~# '^https\?:.*'
  let l:pasting_bracketed_link = l:to_paste =~# '^<https\?:.*>'
  let l:cursor_in_link = has('nvim')
        \ && v:lua.require'magic_link_paste'.is_cursor_in_markdown_link_url()

  " Store the register so we reuse it for the next paste operation (repeat.vim)
  silent! call repeat#setreg("\<Plug>(magic_link_paste-markdown)", l:reg)

  if (l:pasting_link || l:pasting_bracketed_link) && !l:cursor_in_link
    " need to insert second bracket first, because otherwise inserting the
    " opening bracket could move the end of the text relative to `>
    execute "normal! `>a]\<Esc>`<i[\<Esc>%a()\<Esc>\"" . l:reg . 'PF]%'
  else
    execute "normal! p"
  endif

  " Setup repeat for repeat.vim
  silent! call repeat#set("\<Plug>(magic_link_paste-markdown)")
endfunction
