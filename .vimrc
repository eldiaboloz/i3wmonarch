set nocompatible              " be iMproved, required
set backspace=indent,eol,start
filetype off                  " required

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
Plugin 'scrooloose/nerdtree'

call vundle#end()            " required
filetype plugin indent on    " required

syntax on
filetype plugin indent on
" show line numbers
"set number
" show relative line numbers
set relativenumber
set laststatus=2
set encoding=utf-8
set t_Co=256
"set cul
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
"autocmd vimenter * NERDTree
map <C-n> :NERDTreeToggle<CR>
nmap <silent> <A-Up> :wincmd k<CR>
nmap <silent> <A-Down> :wincmd j<CR>
nmap <silent> <A-Left> :wincmd h<CR>
nmap <silent> <A-Right> :wincmd l<CR>

fu! SaveSess()
    execute 'mksession! /work/tmp/.session.vim'
endfunction

fu! RestoreSess()
if filereadable('/work/tmp/.session.vim')
    execute 'so /work/tmp/.session.vim'
    if bufexists(1)
        for l in range(1, bufnr('$'))
            if bufwinnr(l) == -1
                exec 'sbuffer ' . l
            endif
        endfor
    endif
endif
syntax on
endfunction

"autocmd VimLeave * call SaveSess()
"autocmd VimEnter * call RestoreSess()
