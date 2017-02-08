" ============================================================================
" FILE: replica.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" Easy REPL in Vim.
" }}}
" ============================================================================
let s:save_cpo = &cpo
set cpo&vim

" {{{ global variables
let g:replica#prompt = get(g:, 'replica#prompt', '> ')
let g:replica#max_nlines = get(g:, 'replica#max_nlines', 1000)
" }}}
" {{{ Script local variables
let s:internal_repls = add(map(filter(['lua', 'mzscheme', 'perl', 'python', 'python3', 'ruby', 'tcl'], 'has(v:val)'), '{
      \ "name": v:val,
      \ "prefix": v:val
      \}'), {
      \ 'name': 'vim',
      \ 'prefix': ''
      \})
let s:ANSI = vital#replica#import('Vim.Buffer.ANSI')
" }}}

function! replica#repl(name) abort " {{{
  if !executable(a:name)
    echoerr '[replica] Unable to execute' a:name
    return
  endif
  execute 'botright' g:replica#max_nlines 'new [replica]'
  setlocal nobuflisted bufhidden=unload buftype=nofile
  call setline(1, '*[vim-replica]*')
  call s:ANSI.define_syntax()
  let job_id = job_start(a:name, {
        \ 'callback': function('s:on_out'),
        \ 'exit_cb': function('s:on_exit'),
        \ 'out_mode': 'raw',
        \ 'err_mode': 'raw'
        \})
  sleep 100m
  if job_status(job_id) !=# 'run'
    echoerr '[replica] Unable to launch:' a:name
    return
  endif
  try
    while job_status(job_id) ==# 'run'
      let line = input(g:replica#prompt)
      call setline(line('$'), getline('$') . line)
      call ch_sendraw(job_id, line . "\n")
      sleep 50m
    endwhile
    bwipeout!
  catch
    call job_stop(job_id)
    bwipeout!
  endtry
endfunction " }}}

function! replica#repl_internal(...) abort " {{{
  let name = a:0 > 0 ? a:1 : 'vim'
  let items = filter(copy(s:internal_repls), '!stridx(tolower(v:val.name), name)')
  if empty(items)
    echoerr '[replica]' name 'is not available'
    return
  endif
  execute 'botright' g:replica#max_nlines 'new [replica]'
  setlocal nobuflisted bufhidden=unload buftype=nofile
  call setline(line('$'), g:replica#prompt)
  redraw
  let [prefix, input] = [items[0].prefix, input(g:replica#prompt)]
  while input !=# 'exit'
    try
      let line = execute(prefix . input)
      call setline(line('$'), getline('$') . input)
      call s:on_out(v:null, line)
    catch /^Vim:Interrupt$/
      call s:on_exit()
      return
    catch
      call setline(line('$'), g:replica#prompt . input)
      call s:on_out(v:null, v:exception)
    endtry
    call setline(line('$') + 1, g:replica#prompt)
    redraw
    let input = input(g:replica#prompt)
  endwhile
  call s:on_exit()
endfunction " }}}

function! replica#complete_repl_internal(arglead, cmdline, cursorpos) abort " {{{
  let arglead = tolower(a:arglead)
  return filter(map(copy(s:internal_repls), 'v:val.name'), '!stridx(tolower(v:val), arglead)')
endfunction " }}}


function! s:on_out(job_id, out) abort " {{{
  call setline(line('$') + 1, split(a:out, "\n"))
  if line('$') > g:replica#max_nlines
    execute '1,' (line('$') - g:replica#max_nlines) 'delete'
  endif
  normal! G
  redraw
endfunction " }}}

function! s:on_exit(...) abort " {{{
  " bwipeout!
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo
