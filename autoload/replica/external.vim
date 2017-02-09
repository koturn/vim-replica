let s:Job = vital#replica#import('System.Job')


function! replica#external#repl(args) abort
  let args = split(a:args)
  let name = get(args, 0)
  if !executable(name)
    echoerr '[replica]' name 'is not executable'
    return
  endif
  let repl = {
        \ 'type': 'ext',
        \ 'name': name,
        \ 'args': args,
        \ 'complement': copy(s:complement),
        \}
  call replica#open(repl)
endfunction


" Complement instance --------------------------------------------------------
let s:complement = {}

function! s:complement.init() abort
  if has_key(self, 'job')
    call self.job.stop()
  endif
  let self.job = s:Job.start(self.repl.args, {
        \ 'replica': self,
        \ 'on_stdout': function('s:on_stdout'),
        \ 'on_stderr': function('s:on_stderr'),
        \})
  " Change a buffer name based on the job id
  execute printf(
        \ 'keepalt keepjumps file replica://%s:%d',
        \ self.repl.name,
        \ self.job.id(),
        \)
endfunction

function! s:complement.exit() abort
  if has_key(self, 'job')
    call self.job.stop()
  endif
endfunction

function! s:complement.request(data) abort
  if self.job.status() ==# 'run'
    call self.job.send(join(a:data, "\n"))
  else
    echohl WarningMsg
    echo '[replica] The process has terminated.'
    echohl None
  endif
endfunction

function! s:on_stdout(job, msg, event) abort dict
  call self.replica.recieved(a:msg)
endfunction

function! s:on_stderr(job, msg, event) abort dict
  redraw
  echohl ErrorMsg
  for line in a:msg
    echomsg '[replica]' line
  endfor
  echohl None
endfunction
