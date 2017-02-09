function! replica#internal#repl(args) abort
  let repl = get(s:filter(a:args), 0)
  if empty(repl)
    echoerr '[replica]' a:args 'is not available'
    return
  endif
  let repl = {
        \ 'type': 'int',
        \ 'name': repl.name,
        \ 'command': repl.command,
        \ 'format': repl.format,
        \ 'complement': copy(s:complement),
        \}
  call replica#open(repl)
endfunction

function! replica#internal#comp(arglead, cmdline, cursorpos) abort
  let repls = s:filter(a:arglead)
  return map(copy(repls), 'v:val.name')
endfunction


" Private --------------------------------------------------------------------
function! s:filter(prefix) abort
  let prefix = tolower(a:prefix)
  return filter(copy(s:REPLS), '!stridx(tolower(v:val.name), a:prefix)')
endfunction


" Complement instance --------------------------------------------------------
let s:complement = {}

function! s:complement.init() abort
  call self.recieved([g:replica#internal#prompt])
endfunction

function! s:complement.request(data) abort
  try
    let result = execute(printf('%s %s',
          \ self.repl.command,
          \ printf(self.repl.format, join(a:data, "\n"))
          \))
    call self.recieved(
          \ split(result, '\r\?\n') + [g:replica#internal#prompt]
          \)
  catch /^Vim:Interrupt$/
    echoerr '[replica]' v:exception . "\n"
  catch
    call self.recieved(
          \ split(v:exception, '\r\?\n') + [g:replica#internal#prompt]
          \)
  endtry
endfunction


" REPLs ----------------------------------------------------------------------
let s:REPLS = [
      \ {
      \   'name': 'vim',
      \   'command': '',
      \   'format': 'echo %s'
      \ },
      \ {
      \   'name': 'lua',
      \   'command': 'lua',
      \   'format': '%s'
      \ },
      \ {
      \   'name': 'mzscheme',
      \   'command': 'mzscheme',
      \   'format': '%s'
      \ },
      \ {
      \   'name': 'perl',
      \   'command': 'perl',
      \   'format': 'print %s'
      \ },
      \ {
      \   'name': 'python',
      \   'command': 'python',
      \   'format': 'print(%s)'
      \ },
      \ {
      \   'name': 'python3',
      \   'command': 'python3',
      \   'format': 'print(%s)'
      \ },
      \ {
      \   'name': 'ruby',
      \   'command': 'ruby',
      \   'format': '%s'
      \ },
      \ {
      \   'name': 'tcl',
      \   'command': 'tcl',
      \   'format': '%s'
      \ },
      \]
" Remove unvaliable REPLs
call filter(s:REPLS, 'empty(v:val.command) || has(v:val.command)')


" Default config -------------------------------------------------------------
let g:replica#internal#prompt = get(g:, 'replica#internal#prompt', '>>> ')
