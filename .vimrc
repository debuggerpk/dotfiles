" (N)Vim Configuration File
" vim  : place in $HOME/.vimrc
" nvim : place in $HOME/.config/nvim/init.vim
" $ ln -s $HOME/.config/nvim/init.vim $HOME/.vimrc
" General settings
" https://learnvimscriptthehardway.stevelosh.com/
" ---------------------------------------------------------------------------
" drop vi support - kept for vim compatibility but not needed for nvim
" Probably not needed with Vim 8+
"set nocompatible

" Search recursively downward from CWD; provides TAB completion for filenames
" e.g., `:find vim* <TAB>`
set path+=**

" number of lines at the beginning and end of files checked for file-specific vars
set modelines=0

" reload files changed outside of Vim not currently modified in Vim (needs below)
set autoread

" http://stackoverflow.com/questions/2490227/how-does-vims-autoread-work#20418591
au FocusGained,BufEnter * :silent! !

" use Unicode
set encoding=utf-8

" errors flash screen rather than emit beep
set visualbell

" make Backspace work like Delete
set backspace=indent,eol,start

" don't create `filename~` backups
set nobackup

" don't create temp files
set noswapfile

" line numbers and distances
set relativenumber 
set number 

" number of lines offset when jumping
set scrolloff=2

" Tab key enters 2 spaces
" To enter a TAB character when `expandtab` is in effect,
" CTRL-v-TAB
set expandtab tabstop=2 shiftwidth=2 softtabstop=2 

" Indent new line the same as the preceding line
set autoindent

" statusline indicates insert or normal mode
set showmode showcmd

" make scrolling and painting fast
" ttyfast kept for vim compatibility but not needed for nvim
set ttyfast lazyredraw

" highlight matching parens, braces, brackets, etc
set showmatch

" http://vim.wikia.com/wiki/Searching
set hlsearch incsearch ignorecase smartcase

" As opposed to `wrap`
"set nowrap

" http://vim.wikia.com/wiki/Set_working_directory_to_the_current_file
set autochdir

" open new buffers without saving current modifications (buffer remains open)
set hidden

" http://stackoverflow.com/questions/9511253/how-to-effectively-use-vim-wildmenu
set wildmenu wildmode=list:longest,full

" StatusLine always visible, display full path
" http://learnvimscriptthehardway.stevelosh.com/chapters/17.html
set laststatus=2 statusline=%F

" Use system clipboard
" http://vim.wikia.com/wiki/Accessing_the_system_clipboard
" for linux
"set clipboard=unnamedplus
" for macOS
set clipboard=unnamed

" Folding
" https://vim.fandom.com/wiki/Folding
" https://vim.fandom.com/wiki/All_folds_open_when_opening_a_file
" https://stackoverflow.com/questions/8316139/how-to-set-the-default-to-unfolded-when-you-open-a-file
set foldmethod=indent
set foldnestmax=1
set foldlevelstart=1

" netrw and vim-vinegar
let g:netrw_browse_split = 3

" Plugins, syntax, and colors
" ---------------------------------------------------------------------------
" vim-plug
" https://github.com/junegunn/vim-plug
" Specify a directory for plugins
" - For Neovim: ~/.local/share/nvim/plugged
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/.local/share/nvim/plugged')

" Make sure to use single quotes
" Install with `:PlugInstall`

" https://github.com/vim-airline/vim-airline
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'

" https://github.com/tpope/vim-commentary
Plug 'tpope/vim-commentary'

" https://github.com/tpope/vim-fugitive
Plug 'tpope/vim-fugitive'

" https://github.com/tpope/vim-surround
Plug 'tpope/vim-surround'

" https://github.com/tpope/vim-vinegar
Plug 'tpope/vim-vinegar'

" https://github.com/APZelos/blamer.nvim
Plug 'APZelos/blamer.nvim'

" https://github.com/ycm-core/YouCompleteMe
Plug 'Valloric/YouCompleteMe'

" https://github.com/editorconfig/editorconfig-vim
Plug 'editorconfig/editorconfig-vim'

" https://github.com/Mofiqul/dracula.nvim
Plug 'dracula/vim', { 'as': 'dracula' }

" Initialize plugin system
call plug#end()

syntax enable

" Neovim only
set termguicolors 

" Show character column
set colorcolumn=120

" Dracula Theme
colorscheme dracula

" Plugin settings
colorscheme dracula
let g:airline_theme='dracula'
let g:airline_powerline_fonts=1
let g:blamer_enabled = 1
let g:blamer_date_format = '%e %b %Y'
