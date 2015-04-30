scriptencoding utf-8

" Defaults
set nocompatible
set title
set ttyfast
set ruler
set laststatus=2

" Load pathogen which is used for easy plugin handling
execute pathogen#infect()

" Proper backup and tmp dirs are prefered
set backup
set backupdir=~/.vim/backup//
set directory=~/.vim/tmp//

" Enable autosave and undofiles
au FocusLost * :wa

if has('persistent_undo')
    set undofile
    set undodir=~/.vim/undo//
endif

" Don't wrap lines at all
set nowrap

" Turn on line numbers
set nu

" Highlight currentline
set cursorline

" Highlight margin
if exists('+colorcolumn')
    execute "set colorcolumn=" . join(range(81,335), ',')
    autocmd bufenter * highlight ColorColumn ctermbg=235 guibg=#2c2d27
endif

" Allow 256 color themes
set term=screen-256color
set t_Co=256

" Turn on syntax highlighting and set theme
syntax on
set background=dark
colorscheme xoria256

" Yes, we want proper indent support here
set autoindent
filetype plugin indent on

autocmd FileType make set noexpandtab shiftwidth=8 softtabstop=0

" Set some tab stuff here
set shiftwidth=4
set softtabstop=4
set tabstop=4
set smarttab
set expandtab

" Use system-wide clipboard
set clipboard=unnamed

" File handling stuff
set fileformat=unix
set encoding=utf-8

" Search
set gdefault
set incsearch
set showmatch
set hlsearch
set smartcase " lowercase search = case-insensitve


" SOME MAPPING
" Use w!! if sudo was forgotton
cmap w!! w !sudo tee % >/dev/null

" Disable arrow keys
noremap <Up> <NOP>
noremap <Down> <NOP>
noremap <Left> <NOP>
noremap <Right> <NOP>

" Reset search highlights
let mapleader=','
nmap <Leader><space> :noh<CR>

" Easy way to toggle paste mode within insert mode
set pastetoggle=<F2>


" PLUGIN CONFIGURATION

" NERDTree
map <C-n> :NERDTreeToggle<CR>
let NERDTreeShowHidden=1
let NERDTreeMinimalUI=1
" autocmd vimenter * if !argc() | NERDTree | endif
" autocmd vimenter * NERDTree
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTreeType") && b:NERDTreeType == "primary") | q | endif

" Tagbar
nmap <F8> :TagbarToggle<CR>
let g:tagbar_compact=1
let g:tagbar_iconchars = ['▸', '▾']
" autocmd vimenter * nested TagbarOpen

" DONT DO THAT AT HOME :x (this needs definitely a better approach! ;x)
" This is a naive function to stack NERDTree and tagbar on the left side
function! JiggleWindows()
    wincmd l
    wincmd l
    wincmd K
    wincmd j
    wincmd K
    wincmd j
    wincmd j
    wincmd L
    wincmd h
    vertical resize 25
    wincmd l
endfunction
" Call the jiggle function when vim starts
" autocmd vimenter * call JiggleWindows()

