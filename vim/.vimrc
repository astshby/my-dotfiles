" ============================================================
" 基础设置
" ============================================================

set nocompatible

filetype plugin indent on
syntax enable

set hidden
set number
set ruler

set ignorecase
set smartcase
set incsearch
set hlsearch

set tabstop=4
set softtabstop=4
set shiftwidth=4
set expandtab

set autoindent
set smartindent

set backspace=indent,eol,start

set scrolloff=4

if has('clipboard')
    set clipboard=unnamed,unnamedplus
endif

if has('mouse')
    set mouse=a
endif


" ============================================================
" 输入法
" ============================================================

let g:last_ime_state = ''


function! s:IMELeaveInsert()
    " Windows / WSL：Microsoft 拼音
    if executable('AIMSwitcher.exe')
        let g:last_ime_state =
            trim(system(
            \ 'AIMSwitcher.exe --imm'
            \ ))

        call system(
        \ 'AIMSwitcher.exe --imm 0'
        \ )

        return
    endif

    " Linux：Fcitx5
    if executable('fcitx5-remote')
        let g:last_ime_state =
            trim(system(
            \ 'fcitx5-remote'
            \ ))

        if g:last_ime_state ==# '2'
            call system(
            \ 'fcitx5-remote -c'
            \ )
        endif
    endif
endfunction


function! s:IMEEnterInsert()
    " Windows / WSL
    if executable('AIMSwitcher.exe')
        if g:last_ime_state !=# ''
            \ && g:last_ime_state !=# '0'

            call system(
            \ 'AIMSwitcher.exe --imm '
            \ . g:last_ime_state
            \ )
        endif

        return
    endif

    " Linux
    if executable('fcitx5-remote')
        if g:last_ime_state ==# '2'
            call system(
            \ 'fcitx5-remote -o'
            \ )
        endif
    endif
endfunction


augroup auto_input_method
    autocmd!

    autocmd InsertLeave *
        \ call <SID>IMELeaveInsert()

    autocmd InsertEnter *
        \ call <SID>IMEEnterInsert()

augroup END
