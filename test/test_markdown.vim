" Headless test suite for magic-link-paste.
" Run with: make test  (or: nvim --headless -u NONE -S test/test_markdown.vim)
"
" Each test calls s:check; on any failure the script exits non-zero via
" :cquit so the Makefile can detect it.

let s:script_dir = expand('<sfile>:p:h')
let s:repo_root = fnamemodify(s:script_dir, ':h')
execute 'set runtimepath+=' . fnameescape(s:repo_root)
runtime plugin/magic-link-paste.vim
runtime autoload/magic_link_paste/markdown.vim
set noswapfile

let s:fail = 0
function! s:check(name, cond, detail) abort
  if a:cond
    echo 'PASS [' . a:name . ']'
  else
    let s:fail = 1
    echo 'FAIL [' . a:name . '] ' . a:detail
  endif
endfunction

" --- paste() integration tests ---
function! s:run_paste(buf, reg, start, right) abort
  enew!
  set filetype=markdown
  call setline(1, a:buf)
  call setreg('"', a:reg)
  call cursor(1, a:start)
  execute 'normal! v' . a:right . 'l'
  call magic_link_paste#markdown#paste()
  call feedkeys('', 'x')
  return getline(1)
endfunction

call s:check('paste-forward',
      \ s:run_paste('Here is Example text', 'https://example.com', 9, 6)
      \   ==# 'Here is [Example](https://example.com) text', '')
call s:check('paste-reverse',
      \ s:run_paste('See https://sus.cat here', 'Sus Cat', 5, 14)
      \   ==# 'See [Sus Cat](https://sus.cat) here', '')
call s:check('paste-reverse-autolink',
      \ s:run_paste('See <https://sus.cat> here', 'Sus Cat', 5, 16)
      \   ==# 'See [Sus Cat](<https://sus.cat>) here', '')
call s:check('paste-reverse-trailing-space',
      \ s:run_paste('See https://sus.cat  here', 'Sus Cat', 5, 15)
      \   ==# 'See Sus Cat here', '')

let g:magic_link_paste_wrap_bare_urls = 0
call s:check('paste-reverse-disabled',
      \ s:run_paste('See https://sus.cat here', 'Sus Cat', 5, 14)
      \   ==# 'See Sus Cat here', '')
unlet g:magic_link_paste_wrap_bare_urls

call s:check('paste-plain',
      \ s:run_paste('one two three', 'XYZ', 5, 2) ==# 'one XYZ three', '')

" Goes through the buffer-local mapping so that v:register is set the way it
" is for a real `"ap`.
function! s:run_mapped_paste(buf, regname, reg, start, right) abort
  enew!
  set filetype=markdown
  call setline(1, a:buf)
  call setreg(a:regname, a:reg)
  call setreg('"', 'UNNAMED')
  call cursor(1, a:start)
  execute 'normal v' . a:right . 'l"' . a:regname . 'p'
  call feedkeys('', 'x')
  return getline(1)
endfunction

call s:check('paste-plain-named-register',
      \ s:run_mapped_paste('one two three', 'a', 'XYZ', 5, 2)
      \   ==# 'one XYZ three', '')
call s:check('paste-forward-named-register',
      \ s:run_mapped_paste('Here is Example text', 'a',
      \                    'https://example.com', 9, 6)
      \   ==# 'Here is [Example](https://example.com) text', '')

" --- vim.paste override (Neovim only) ---
function! s:run_vim_paste(buf, paste, start, right, ft) abort
  enew!
  execute 'set filetype=' . a:ft
  call setline(1, a:buf)
  call cursor(1, a:start)
  execute 'normal! v' . a:right . 'l'
  call v:lua.vim.paste([a:paste], -1)
  sleep 100m
  call feedkeys('', 'x')
  return getline(1)
endfunction

if has('nvim')
  call s:check('vim-paste-forward',
        \ s:run_vim_paste('Here is Example text',
        \                  'https://example.com', 9, 6, 'markdown')
        \   ==# 'Here is [Example](https://example.com) text', '')
  call s:check('vim-paste-reverse',
        \ s:run_vim_paste('See https://sus.cat here',
        \                  'Sus Cat', 5, 14, 'markdown')
        \   ==# 'See [Sus Cat](https://sus.cat) here', '')
  call s:check('vim-paste-non-md',
        \ s:run_vim_paste('hello world foo',
        \                  'https://example.com', 7, 4, 'text')
        \   ==# 'hello https://example.com foo', '')
endif

if s:fail | cquit | else | qa! | endif
