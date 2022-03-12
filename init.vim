" general settings
set nocompatible
set number
set termguicolors
set ignorecase
set smartcase
set splitright
set splitbelow
set mouse=n
set nowrap
set clipboard=unnamedplus
autocmd CompleteDone * pclose
map <F8> :setlocal spell! spelllang=en_gb<CR>

" Plugins
let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
if empty(glob(data_dir . '/autoload/plug.vim'))
  silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin(stdpath('data') . '/plugged')
call plug#begin()
Plug 'lervag/vimtex'
Plug 'tpope/vim-commentary'
Plug 'neovim/nvim-lspconfig'
Plug 'LnL7/vim-nix'
call plug#end()

" LSP setup
lua require('lspconfig').pyright.setup{}
lua require('lspconfig').rnix.setup{}

" LaTeX/vimtex settings 
let g:vimtex_complete_enabled = 1
let g:tex_flavor = 'latex'
autocmd FileType tex autocmd VimLeave * :VimtexClean
autocmd FileType tex,md setlocal textwidth=80
