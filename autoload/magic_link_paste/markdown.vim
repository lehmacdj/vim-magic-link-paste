xnoremap <Plug>(magic_link_paste-markdown) <Cmd>call magic_link_paste#markdown#paste()<CR>

" strict=1 requires the text to be exactly a URL (or autolink) with no
" trailing chars. strict=0 only requires a URL prefix (clipboard often
" carries trailing whitespace or newlines).
function! s:is_url(text, strict) abort
  if a:strict
    return a:text =~# '^https\?:\/\/\S\+$'
          \ || a:text =~# '^<https\?:\/\/\S\+>$'
  else
    return a:text =~# '^https\?:.*' || a:text =~# '^<https\?:.*>'
  endif
endfunction

" If the current visual selection is exactly a single-line bare URL
" (or autolink), returns [lnum, scol, ecol, url_text]. Returns [] if
" the selection is not eligible for the paste-text-over-URL wrap.
function! s:url_selection() abort
  if mode() !=# 'v' | return [] | endif

  let [l:lnum_s, l:col_s] = getpos("v")[1:2]
  let [l:lnum_e, l:col_e] = getpos(".")[1:2]
  if l:lnum_s > l:lnum_e || (l:lnum_s == l:lnum_e && l:col_s > l:col_e)
    let [l:lnum_s, l:col_s, l:lnum_e, l:col_e]
          \ = [l:lnum_e, l:col_e, l:lnum_s, l:col_s]
  endif
  if l:lnum_s != l:lnum_e | return [] | endif

  let l:line = getline(l:lnum_s)
  let l:scol = l:col_s - 1
  let l:ecol = &selection ==# 'exclusive' ? l:col_e - 1 : l:col_e
  let l:ecol = min([l:ecol, strlen(l:line)])
  let l:sel = strpart(l:line, l:scol, l:ecol - l:scol)

  if !s:is_url(l:sel, 1) | return [] | endif
  return [l:lnum_s, l:scol, l:ecol, l:sel]
endfunction

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
  let l:pasting_url = s:is_url(l:to_paste, 0)
  let l:cursor_in_link = has('nvim')
        \ && v:lua.require'magic_link_paste'.is_cursor_in_markdown_link_url()

  let l:url_sel = !l:cursor_in_link && !l:pasting_url
        \ && get(g:, 'magic_link_paste_wrap_bare_urls', 1)
        \ ? s:url_selection() : []

  " Store the register so we reuse it for the next paste operation (repeat.vim)
  silent! call repeat#setreg("\<Plug>(magic_link_paste-markdown)", l:reg)

  if l:pasting_url && !l:cursor_in_link
    " need to insert second bracket first, because otherwise inserting the
    " opening bracket could move the end of the text relative to `>
    call feedkeys("\<Esc>`>a]\<Esc>`<i[\<Esc>%a()\<Esc>\"" . l:reg . 'PF]%', 'n')
  elseif !empty(l:url_sel)
    let [l:lnum, l:scol, l:ecol, l:sel] = l:url_sel
    let l:line = getline(l:lnum)
    let l:replacement = '[' . l:to_paste . '](' . l:sel . ')'
    let l:new_line = strpart(l:line, 0, l:scol)
          \ . l:replacement . strpart(l:line, l:ecol)
    execute "normal! \<Esc>"
    call setline(l:lnum, l:new_line)
    call cursor(l:lnum, l:scol + strlen(l:replacement))
  else
    execute 'normal! "' . l:reg . 'p'
  endif

  " Setup repeat for repeat.vim
  silent! call repeat#set("\<Plug>(magic_link_paste-markdown)")
endfunction
