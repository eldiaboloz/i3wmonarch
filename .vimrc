set nocompatible              " be iMproved, required
set backspace=indent,eol,start
filetype off                  " required

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab
" set list
"set list
"set listchars=tab:>-
"set lcs+=space:·

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'VundleVim/Vundle.vim'
Plugin 'tpope/vim-fugitive'
Plugin 'vim-airline/vim-airline' 
Plugin 'vim-airline/vim-airline-themes'
Plugin 'L9'
Plugin 'git://git.wincent.com/command-t.git'
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
Plugin 'mhinz/vim-signify'
Plugin 'altercation/vim-colors-solarized'

call vundle#end()            " required
filetype plugin indent on    " required

syntax on
" show line numbers
set number
" show relative line numbers
"set relativenumber
set laststatus=2
set encoding=utf-8
set t_Co=256
set cul
if !exists('g:airline_symbols')
	let g:airline_symbols = {}
endif

let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#fnamemod = ':t:r'

let g:airline_theme="solarized"
let g:airline_solarized_bg="dark"

"colorscheme solarized
set background=light
"set clipboard=unnamedplus
set ignorecase
set smartcase

" setup undofile and undo-dir
if !isdirectory($HOME."/.vim")
    call mkdir($HOME."/.vim", "", 0700)
endif
if !isdirectory($HOME."/.vim/undo-dir")
    call mkdir($HOME."/.vim/undo-dir", "", 0700)
endif

set undodir=~/.vim/undo-dir
set undofile " Maintain undo history between session

autocmd Filetype yaml setlocal tabstop=2 shiftwidth=2 softtabstop=2
