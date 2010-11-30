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

function! s:copy_template(src, dest) "{{{
    if executable('cp')
        call s:system('cp', '-R', a:src, a:dest)
        return 1
    else
        call s:echomsg(
        \   'ErrorMsg',
        \   's:copy_template(): not implemented!!'
        \)
        call s:echomsg(
        \   'ErrorMsg',
        \   "sorry! current starter.vim needs 'cp' program"
        \       . ' for copying template directory.'
        \)
        return 0
    endif
endfunction "}}}

function! s:generate_template(path) "{{{
    if has_key(g:starter_hook_program, a:path)
        let program = g:starter_hook_program[a:path]
        if type(program) == type("")
            call system(program . ' ' . shellescape(a:path))
        elseif type(program) == type({})
            call system(
            \   program.program . ' '
            \       . shellescape(a:path)
            \       . join(
            \           map(program.args,
            \               'shellescape(v:val)'))
            \)
        else
            call s:echomsg(
            \   'WarningMsg',
            \   'invalid value in g:starter_hook_program:'
            \       . ' key = ' . string(a:path)
            \       . ', value = ' . string(program)
            \)
        endif
    endif
endfunction "}}}

function! s:generate() "{{{
    let idx = line('.') - 1
    if !(0 <= idx && idx < len(b:starter_files_list))
        call s:echomsg(
        \   'ErrorMsg',
        \   'internal error: invalid lnum.''internal error: invalid lnum.'
        \)
        return
    endif
    let file = b:starter_files_list[idx]

    let dest = substitute(getcwd(), '\', '/', 'g') . '/'
    if getftype(dest) != ''
        call s:echomsg(
        \   'ErrorMsg',
        \   "path '" . dest . "' exists."
        \)
        return
    endif
    if !s:copy_template(file, dest)
        return
    endif
    call s:generate_template(dest)
endfunction "}}}

function! s:create_buffer(files) "{{{
    execute g:starter_open_command

    " Options
    setlocal bufhidden=wipe
    setlocal buftype=nofile
    setlocal cursorline
    setlocal nobuflisted
    setlocal noswapfile

    call setline(1, a:files)
    setlocal nomodifiable

    " Mappings
    nnoremap <buffer> <Plug>(starter-create) :<C-u>call <SID>generate()<CR>
    nnoremap <buffer> <Plug>(starter-close)  :<C-u>close<CR>

    nmap <buffer> <CR>   <Plug>(starter-create)
    nmap <buffer> <Esc>  <Plug>(starter-close)

    " End.
    file [starter]
    setfiletype starter
endfunction "}}}

function! s:remove_base_path(path, base_path) "{{{
    " FIXME: this won't work for directories in template dir.
    return fnamemodify(a:path, ':t')
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

    let files = s:glob(template_dir . '/*')
    call s:create_buffer(
    \   map(
    \       copy(files),
    \       's:remove_base_path(v:val, template_dir)'
    \   )
    \)
    let b:starter_files_list = files
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
