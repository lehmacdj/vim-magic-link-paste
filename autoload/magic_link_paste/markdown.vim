" Emulates the behavior of apps like slack where pasting a link over a
" selection turns the selection into a link.
"
" Intended to be mapped like so for filetypes that use markdown link syntax:
" xmap <buffer> <expr> p markdown_magic_link_paste#visual_expr_mapping()
" This is done automatically for the markdown filetype by the plugin unless
" disabled.
function! magic_link_paste#markdown#paste() abort
  let l:reg = get(v:, 'register', '"')
  let l:to_paste = getreg(l:reg)
  let l:pasting_link = l:to_paste =~# '^https\?:.*'
  let l:pasting_bracketed_link = l:to_paste =~# '^<https\?:.*>'
  let l:cursor_in_link = has('nvim')
        \ && v:lua.require'magic_link_paste'.is_cursor_in_markdown_link_url()

  if (l:pasting_link || l:pasting_bracketed_link) && !l:cursor_in_link
    return "\<Esc>`<i[\<Esc>`>a]()\<Esc>\"" . l:reg . 'PF]%'
  else
    return 'p'
  endif
endfunction
