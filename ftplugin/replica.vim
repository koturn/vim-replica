if exists('b:did_ftplugin')
  finish
endif
let b:did_ftplugin = 1

setlocal nobuflisted
setlocal nolist nospell
setlocal nowrap nofoldenable
setlocal nonumber norelativenumber
setlocal foldcolumn=0 colorcolumn=0

nmap <buffer> i <Plug>(replica-start)
nmap <buffer> I <Plug>(replica-start)
nmap <buffer> a <Plug>(replica-start)
nmap <buffer> A <Plug>(replica-start)
nmap <buffer> o <Plug>(replica-start)
nmap <buffer> O <Plug>(replica-start)
nmap <buffer> gi <Plug>(replica-start-cword)
nmap <buffer> gI <Plug>(replica-start-cword)
nmap <buffer> ga <Plug>(replica-start-cword)
nmap <buffer> gA <Plug>(replica-start-cword)
nmap <buffer> go <Plug>(replica-start-cword)
nmap <buffer> gO <Plug>(replica-start-cword)
nmap <buffer> p <Plug>(replica-start-paste)
nmap <buffer> P <Plug>(replica-start-paste)
