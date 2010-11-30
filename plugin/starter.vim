" vim:foldmethod=marker:fen:
scriptencoding utf-8

" Change Log: {{{
" }}}
" Document {{{
"
" Name: starter
" Version: 0.0.0
" Author:  tyru <tyru.exe@gmail.com>
" Last Change: 2010-11-30.
" License: Distributable under the same terms as Vim itself (see :help license)
"
" Description:
"   NO DESCRIPTION YET
"
" Usage: {{{
"   Commands: {{{
"   }}}
"   Mappings: {{{
"   }}}
"   Global Variables: {{{
"   }}}
" }}}
" }}}

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


" Global Variables
if !exists('g:starter_template_dir')
    let g:starter_template_dir = '~/.vim/template'
endif
if !exists('g:starter_open_command')
    let g:starter_open_command = '5new'
endif
if !exists('g:starter_no_default_command')
    let g:starter_no_default_command = 0
endif
if !exists('g:starter_hook_program')
    let g:starter_hook_program = {}
endif



function! s:glob(...) "{{{
    return split(call('glob', a:000), '\n')
endfunction "}}}

function! s:system(...) "{{{
    return call('system',
    \       join(map(copy(a:000), 'shellescape(v:val)')))
endfunction "}}}

function! s:echomsg(hl, msg) "{{{
    try
        execute 'echohl' a:hl
        echomsg a:msg
    finally
        echohl None
    endtry
endfunction "}}}

function! s:copy_template_dir(src_dir, dest_dir) "{{{
    if executable('cp')
        call s:system('cp', '-R', a:src_dir, a:dest_dir)
    else
        " TODO
        echoerr 's:copy_template_dir(): not implemented!!'
    endif
endfunction "}}}

function! s:generate_template_dir(dir) "{{{
    if has_key(g:starter_hook_program, a:dir)
        let program = g:starter_hook_program[a:dir]
        if type(program) == type("")
            call system(program . ' ' . shellescape(a:dir))
        elseif type(program) == type({})
            call system(
            \   program.program . ' '
            \       . shellescape(a:dir)
            \       . join(
            \           map(program.args,
            \               'shellescape(v:val)'))
            \)
        else
            call s:echomsg(
            \   'WarningMsg',
            \   'invalid value in g:starter_hook_program:'
            \       . ' key = ' . string(a:dir)
            \       . ', value = ' . string(program)
            \)
        endif
    endif
endfunction "}}}

function! s:generate() "{{{
    let idx = line('.') - 1
    if !(0 <= idx && idx < len(b:starter_dir_list))
        call s:echomsg(
        \   'ErrorMsg',
        \   'internal error: invalid lnum.''internal error: invalid lnum.'
        \)
        return
    endif
    let dir = b:starter_dir_list[idx]
    if !isdirectory(dir)
        call s:echomsg(
        \   'ErrorMsg',
        \   "internal error: '" . dir
        \       . "' is not a directory."
        \)
        return
    endif

    let dest_dir = substitute(getcwd(), '\', '/', 'g') . '/'
    if getftype(dest_dir) != ''
        call s:echomsg(
        \   'ErrorMsg',
        \   "path '" . dest_dir . "' exists."
        \)
        return
    endif
    call s:copy_template_dir(dir, dest_dir)
    call s:generate_template_dir(dest_dir)
endfunction "}}}

function! s:create_buffer(dirs) "{{{
    execute g:starter_open_command

    " Options
    setlocal bufhidden=wipe
    setlocal buftype=nofile
    setlocal cursorline
    setlocal nobuflisted
    setlocal noswapfile

    call setline(1, a:dirs)
    setlocal nomodifiable

    " Mappings
    nnoremap <Plug>(starter-create) :<C-u>call <SID>generate()<CR>
    nnoremap <Plug>(starter-close)  :<C-u>close<CR>

    nmap <CR>   <Plug>(starter-create)
    nmap <Esc>  <Plug>(starter-close)

    " End.
    file [starter]
    setfiletype starter
endfunction "}}}

function! s:launch() "{{{
    let template_dir = expand(g:starter_template_dir)
    if !isdirectory(template_dir)
        call s:echomsg(
        \   'ErrorMsg',
        \   "directory '"
        \       . template_dir
        \       . "' does not exist."
        \)
        return
    endif

    let dirs = 
    \   filter(
    \       s:glob(template_dir . '/*'),
    \       'isdirectory(v:val)'
    \   )
    call s:create_buffer(dirs)
    let b:starter_dir_list = dirs
endfunction "}}}

if !g:starter_no_default_command
    command!
    \   -bar
    \   StarterLaunch
    \   call s:launch()
endif

" Restore 'cpoptions' {{{
let &cpo = s:save_cpo
" }}}
