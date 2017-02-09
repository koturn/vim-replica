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


command! -bar -nargs=* Replica call replica#external#repl(<q-args>)
command! -bar -nargs=?
      \ -complete=customlist,replica#internal#comp
      \ ReplicaInternal call replica#internal#repl(<f-args>)
