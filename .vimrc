set nocompatible              " be iMproved, required
set backspace=indent,eol,start
filetype off                  " required

set tabstop=2
set shiftwidth=2
set softtabstop=2
set expandtab

"set hlsearch

set updatetime=1000

filetype plugin indent on    " required

syntax on
set number
set laststatus=2
set encoding=utf-8
set t_Co=256
set cul

" airline
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#show_buffers = 1
let g:airline#extensions#tabline#fnamemod = ':t:r'

let g:airline_theme="solarized"
let g:airline_solarized_bg="dark"

function! AirlineInit()
  if expand('$UID') == 0
    let g:airline_section_a = 'SU@'.hostname() .' '. g:airline_section_a
  else
    let g:airline_section_a = hostname() .' '. g:airline_section_a
  endif
endfunction
autocmd User AirlineAfterInit call AirlineInit()


" gitgutter
let g:gitgutter_map_keys = 0

set background=light
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
