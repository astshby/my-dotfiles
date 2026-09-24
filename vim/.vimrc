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


" ============================================================
" 剪贴板
" ============================================================

if has('clipboard')
    set clipboard=unnamed,unnamedplus
endif


" ============================================================
" 鼠标
" ============================================================

if has('mouse')
    set mouse=a
endif


" ============================================================
" 输入法自动切换
"
" Windows:
"   AIMSwitcher.exe
"
" WSL:
"   通过 Windows / WSL interop 调用 AIMSwitcher.exe
"
" Native Linux:
"   Fcitx5 / fcitx5-remote
" ============================================================


" 上一次离开 Insert 模式时的输入法状态
let g:last_ime_state = ''


" ------------------------------------------------------------
" 判断当前是否使用 Windows / WSL 的 Microsoft IME
" ------------------------------------------------------------

function! s:UseAIMSwitcher()
    if has('win32') || has('win64')
        return executable('AIMSwitcher.exe')
    endif

    if exists('$WSL_DISTRO_NAME')
        return executable('AIMSwitcher.exe')
    endif

    return 0
endfunction


" ------------------------------------------------------------
" 离开 Insert 模式
"
" 1. 保存当前输入法状态
" 2. 强制切换到英文
" ------------------------------------------------------------

function! s:IMELeaveInsert()

    " Windows / WSL: Microsoft 拼音
    if s:UseAIMSwitcher()
        let g:last_ime_state = trim(system('AIMSwitcher.exe --imm'))
        call system('AIMSwitcher.exe --imm 0')
        return
    endif

    " Native Linux: Fcitx5
    if executable('fcitx5-remote')
        let g:last_ime_state = trim(system('fcitx5-remote'))

        if g:last_ime_state ==# '2'
            call system('fcitx5-remote -c')
        endif

        return
    endif

endfunction


" ------------------------------------------------------------
" 进入 Insert 模式
"
" 恢复离开 Insert 模式之前的输入法状态
" ------------------------------------------------------------

function! s:IMEEnterInsert()

    " Windows / WSL: Microsoft 拼音
    if s:UseAIMSwitcher()

        if g:last_ime_state !=# '' && g:last_ime_state !=# '0'
            call system('AIMSwitcher.exe --imm ' . g:last_ime_state)
        endif

        return
    endif

    " Native Linux: Fcitx5
    if executable('fcitx5-remote')

        if g:last_ime_state ==# '2'
            call system('fcitx5-remote -o')
        endif

        return
    endif

endfunction


" ============================================================
" 自动命令
" ============================================================

augroup auto_input_method
    autocmd!

    autocmd InsertLeave * call <SID>IMELeaveInsert()
    autocmd InsertEnter * call <SID>IMEEnterInsert()

augroup END
