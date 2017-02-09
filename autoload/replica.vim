" ============================================================================
" FILE: replica.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" Easy REPL in Vim.
" }}}
" ============================================================================
let s:ANSI = vital#replica#import('Vim.Buffer.ANSI')
let s:Guard = vital#replica#import('Vim.Guard')
let s:Window = vital#replica#import('Vim.Window')


function! replica#open(repl) abort
  let bufname = printf('replica://%s', a:repl.name)
  execute g:replica#opener bufname
  let b:replica = copy(s:replica)
  let b:replica.repl = a:repl
  let b:replica.bufnr = bufnr('%')
  call extend(b:replica, a:repl.complement)
  setlocal bufhidden=wipe buftype=nowrite
  setlocal noswapfile
  setlocal nomodifiable
  setlocal filetype=replica
  nnoremap <buffer><silent> <Plug>(replica-start)
        \ :<C-u>call replica#start()<CR>
  nnoremap <buffer><silent> <Plug>(replica-start-cword)
        \ :<C-u>call replica#start(expand('<cword>'))<CR>
  nnoremap <buffer><silent> <Plug>(replica-start-paste)
        \ :<C-u>call replica#start(getreg())<CR>
  augroup replica_window
    autocmd! * <buffer>
    autocmd BufReadCmd <buffer> call s:on_BufReadCmd()
    autocmd BufWipeout <buffer> call s:on_BufWipeout()
  augroup END
  doautocmd BufReadCmd
  call replica#start()
endfunction

function! replica#start(...) abort
  if !exists('b:replica')
    echoerr '[replica] No replica instance is found on the buffer'
    return
  endif
  let sleeptime = g:replica#updatetime . 'm'
  let input = s:input(g:replica#prompt, get(a:000, 0, ''))
  while input isnot# v:null
    let content = split(input, '\r\?\n', 1) + ['']
    call b:replica.recieved(content)
    call b:replica.request(content)
    execute 'sleep' sleeptime
    redraw
    let input = s:input(g:replica#prompt)
  endwhile
  redraw | echo
endfunction


" Private --------------------------------------------------------------------
function! s:input(prompt, ...) abort
  cnoremap <buffer><silent> <Esc> <C-u>===ESCAPE===<CR>
  try
    call inputsave()
    redraw
    let result = call('input', [a:prompt] + a:000)
    redraw
    if result ==# '===ESCAPE==='
      return v:null
    endif
    return result
  finally
    call inputrestore()
    cunmap <buffer> <Esc>
  endtry
endfunction

function! s:extend_content(content) abort
  let guard = s:Guard.store(['&l:modifiable'])
  try
    setlocal modifiable
    let leading = getline('$')
    let content = [leading . get(a:content, 0, '')] + a:content[1:]
    silent lockmarks keepjumps $delete _
    silent lockmarks keepjumps call append(line('$'), content)
  finally
    call guard.restore()
  endtry
endfunction

function! s:define_syntax() abort
  call s:ANSI.define_syntax()
  " Wikipedia: ANSI escape code > Non-CSI codes
  syntax match ReplicaSuppressOSC conceal /\e\].\{-}/
endfunction

function! s:on_BufReadCmd() abort
  let replica = getbufvar(expand('<afile>'), 'replica', v:null)
  if replica isnot# v:null
    call s:define_syntax()
    call replica.init()
  endif
endfunction

function! s:on_BufWipeout() abort
  let replica = getbufvar(expand('<afile>'), 'replica', v:null)
  if replica isnot# v:null
    call replica.exit()
  endif
endfunction


" A replica instance ---------------------------------------------------------
let s:replica = {}

function! s:replica.init() abort
endfunction

function! s:replica.exit() abort
endfunction

function! s:replica.recieved(content) abort
  let guard = s:Window.focus_buffer(self.bufnr)
  if guard is# v:null
    return
  endif
  try
    call s:extend_content(a:content)
    normal! G
    redraw
  finally
    call guard.restore()
  endtry
endfunction

function! s:replica.request(content) abort
  throw '[replica] replica.request() is required to be overridden'
endfunction


" Default config -------------------------------------------------------------
let g:replica#opener = get(g:, 'replica#opener', 'vsplit')
let g:replica#prompt = get(g:, 'replica#prompt', '> ')
let g:replica#updatetime = get(g:, 'replica#updatetime', 50)
