" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Load Once {{{
if exists('g:loaded_starter') && g:loaded_starter
    finish
endif
let g:loaded_starter = 1
" }}}
" Saving 'cpoptions' {{{
let s:save_cpo = &cpo
set cpo&vim
" }}}


if !exists('g:starter_no_default_command')
    let g:starter_no_default_command = 0
endif

if !g:starter_no_default_command
    command!
    \   -bar
    \   StarterLaunch
    \   call starter#launch()
endif


" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
