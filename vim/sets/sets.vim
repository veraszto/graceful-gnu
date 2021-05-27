let g:Danvim_current_being_sourced = expand("<SID>")


set updatecount=0
set autoindent	
set smartindent
set title
set tabstop=4	
"So it takes the value of 'ts'
set shiftwidth=0 
set scrolloff=5
set noloadplugins
set nohlsearch
set number
set noshowmode
set nocompatible
set noincsearch
set autoread
set showcmd
set showtabline=2
set laststatus=2
set wmh=0
set wmw=0
set winheight=999
set backspace=2
set wrap
set comments=""
set iskeyword+=-
set shortmess+=A
filetype indent off
filetype plugin off
syntax on


execute "set tabline=%!" . g:Danvim_SID . "BuildTabLine2()"
execute "set statusline=%!" . g:Danvim_SID . "BuildStatusLine2()"
