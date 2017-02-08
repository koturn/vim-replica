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
let s:Job = vital#replica#import('System.Job')
" }}}

function! replica#repl(args) abort " {{{
  let args = split(a:args)
  let name = get(args, 0, '')
  if !executable(name)
    echoerr '[replica] Unable to execute' name
    return
  endif
  execute 'botright' g:replica#max_nlines 'new [replica]'
  setlocal nobuflisted bufhidden=unload buftype=nofile
  call setline(1, '*[vim-replica]*')
  call s:ANSI.define_syntax()
  let job = s:Job.start(args, {
        \ 'on_stdout': function('s:on_stdout'),
        \ 'on_stderr': function('s:on_stdout'),
        \ 'on_exit': function('s:on_exit'),
        \})
  sleep 100m
  if job.status() !=# 'run'
    echoerr '[replica] Unable to launch:' name
    return
  endif
  try
    while job.status() ==# 'run'
      let line = input(g:replica#prompt)
      call setline(line('$'), getline('$') . line)
      call job.send(line . "\n")
      sleep 50m
    endwhile
  catch /^Vim:Interrupt$/
    call job.stop()
  catch
    echoerr v:exception
    call job.stop()
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
      let line = execute(prefix . ' ' . input)
      call setline(line('$'), getline('$') . input)
      call s:on_stdout(v:null, split(line, '\r\?\n'), 'stdout')
    catch /^Vim:Interrupt$/
      call s:on_exit()
      return
    catch
      call setline(line('$'), g:replica#prompt . input)
      call s:on_stdout(v:null, split(v:exception, '\r\?\n'), 'stdout')
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

function! s:on_stdout(job, msg, event) abort " {{{
  echomsg string(a:msg)
  call setline(line('$') + 1, a:msg)
  if line('$') > g:replica#max_nlines
    execute '1,' (line('$') - g:replica#max_nlines) 'delete'
  endif
  normal! G
  redraw
endfunction " }}}

function! s:on_exit(...) abort " {{{
  bwipeout!
endfunction " }}}


let &cpo = s:save_cpo
unlet s:save_cpo
