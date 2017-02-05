" ============================================================================
" FILE: replica.vim
" AUTHOR: koturn <jeak.koutan.apple@gmail.com>
" DESCRIPTION: {{{
" Easy REPL in Vim.
" }}}
" ============================================================================
if exists('g:loaded_replica')
  finish
endif
let g:loaded_replica = 1
let s:save_cpo = &cpo
set cpo&vim


command! -bar -nargs=1 Replica  call replica#repl(<f-args>)
command! -bar -nargs=? -complete=customlist,replica#complete_repl_internal ReplicaInternal  call replica#repl_internal(<f-args>)


let &cpo = s:save_cpo
unlet s:save_cpo
