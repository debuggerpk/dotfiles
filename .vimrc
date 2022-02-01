" =============== General Config ===============

set autoindent                              " indent new lines automatically
set autoread                                " reload files changed outside of Vim not currently modified in Vim (needs below)
set backspace=indent,eol,start              " make Backspace work like Delete
set clipboard=unnamed                       " use system clipboard
set encoding=utf-8                          " set unicode
set foldlevelstart=1                        " start folding at level 1
set foldmethod=indent                       " fold by indentation
set foldnestmax=1                           " don't fold nested folds
set hlsearch incsearch ignorecase smartcase " highlight search terms
set laststatus=2 statusline=%F              " show file name in status bar
set modelines=0                             " number of lines at the beginning and end of files checked for file-specific vars
set nobackup                                " don't create `filename~` backups
set noswapfile                              " don't create temp files
set number                                  " display line numbers
set path+=**                                " search recursively downward from CWD; provides TAB completion for filenames
set relativenumber                          " display line numbers relative to current line
set scrolloff=2                             " scroll 2 lines at a time
set showmatch                               " show matching brackets
set showmode showcmd                        " show command mode
set wildmenu wildmode=list:longest,full     " http://stackoverflow.com/questions/9511253/how-to-effectively-use-vim-wildmenu

au FocusGained,BufEnter * :silent! !        " don't print messages when switching buffers, http://stackoverflow.com/questions/2490227/how-does-vims-autoread-work#20418591

" netrw and vim-vinegar
" let g:netrw_browse_split = 3

" ================== Plugins ==================

call plug#begin('~/.local/share/nvim/plugged')

Plug 'APZelos/blamer.nvim'
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'editorconfig/editorconfig-vim'
Plug 'ryanoasis/vim-devicons'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-vinegar'
Plug 'Valloric/YouCompleteMe'
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-airline/vim-airline'

call plug#end()

" ================== Colors & Theme ==================

syntax enable                               " enable syntax highlighting    
set termguicolors                           " use terminal colors
colorscheme dracula                         " use dracula colorscheme

" ================== Plugins Config ==================

" Plugin settings

" Airline
let g:airline_theme='dracula'               " use dracula theme
let g:airline_powerline_fonts=1             " use powerline fonts

" Blamer
let g:blamer_enabled = 1                    " enable blamer
let g:blamer_date_format = '%e %b %Y'       " use date format

" NerdTree
let g:NERDTreeShowHidden = 1
let g:NERDTreeDirArrows = 1
let g:NERDTreeMinimalUI = 1
let g:NERDTreeIgnore = []
let g:NERDTreeStatusline = ''

" https://stackoverflow.com/questions/5545082/making-nerdtree-work-as-expected/61039352#61039352
autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | wincmd p | ene | exe 'NERDTree' argv()[0] | endif

map <silent> <C-n> :NERDTreeFocus<CR>
