
"------------------------------------
"Plugins
"------------------------------------
call plug#begin()
Plug 'joshdick/onedark.vim'
Plug 'pacokwon/onedarkhc.vim'
Plug 'sainnhe/everforest'
Plug 'rafi/awesome-vim-colorschemes'
Plug 'dense-analysis/ale'

Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
call plug#end()
"------------------------------------
"vim fugitive
"------------------------------------

"------------------------------------
"fzf
"------------------------------------
function! Rooter() abort
	" https://vi.stackexchange.com/questions/20605/find-project-root-relative-to-the-active-buffer/20606
	let l:dir = finddir('.git/..', expand('%:p:h').';')
	"echom 'cwd: ' . l:dir
	execute 'lcd ' . l:dir
endfunction

augroup rooter
	autocmd!
	autocmd BufRead * call Rooter()
augroup END
"------------------------------------
"VIM-LSP
"------------------------------------
highlight link LspErrorHighlight NONE
highlight link LspWarningHighlight NONE

let g:lsp_diagnostics_enabled = 0         " disable diagnostics support
"let g:lsp_inlay_hints_enabled = 0

function g:StartLsp()
	function! OnLspBufferEnabled() abort
	    setlocal omnifunc=lsp#complete
	    setlocal signcolumn=yes
	    nmap <buffer> gi <plug>(lsp-definition)
	    nmap <buffer> gd <plug>(lsp-declaration)
	    nmap <buffer> gr <plug>(lsp-references)
	    nmap <buffer> gl <plug>(lsp-document-diagnostics)
	    nmap <buffer> <f2> <plug>(lsp-rename)
	    nmap <buffer> <f3> <plug>(lsp-hover)
	endfunction
	
	augroup lsp_install
	  au!
	  autocmd User lsp_buffer_enabled call OnLspBufferEnabled()
	augroup END
endfunction
"------------------------------------
"Ale
"------------------------------------
let g:ale_linters = { 'python': ['flake8']}
"------------------------------------
"Colorsheme
"------------------------------------
colorscheme challenger_deep 
set background=dark
let g:everforest_background   = 'soft'
"------------------------------------
set t_ut=                    "Reload vimrc when saving
let mapleader = "\\"
let maplocalleader = "\\"
"------------------------------------
" REQUIRED. This makes vim invoke Latex-Suite when you open a tex file.
filetype plugin on

" IMPORTANT: win32 users will need to have 'shellslash' set so that latex
" can be called correctly.
set shellslash

" OPTIONAL: This enables automatic indentation as you type.
filetype indent on

" OPTIONAL: Starting with Vim 7, the filetype of empty .tex files defaults
"to 'plaintex' instead of 'tex', which results in vim-latex not being loaded.
" The following changes the default filetype back to 'tex':
let g:tex_flavor='latex'
"------------------------------------
syntax   enable

filetype plugin on 
filetype indent on
filetype indent plugin on

set backspace=indent,eol,start
set tabstop=2 shiftwidth=2 expandtab
set shiftwidth=4
set fdm=indent
set ts=8
set et
set sts=4
set ai
set nu
set nowrap
set noexpandtab
set spelllang=en
set nospell
set hlsearch

map <leader>vimrc :tabe ~/.vimrc<cr>
autocmd bufwritepost .vimrc source $MYVIMRC
"----------------------------------------
:vnoremap <Up>     <nop>
:vnoremap <Down>   <nop>
:vnoremap <Right>  <nop>
:vnoremap <Left>   <nop>

:vnoremap cp       "*y
:vnoremap ps       "*p
:vnoremap jk       <esc>
"----------------------------------------
:nnoremap + ddkkp
:nnoremap - ddp

"Turn off highlight
:nnoremap <leader>c    :noh<cr>

"Open fuzzy finder
:nnoremap <leader>f    :FZF<cr>

"Git fugitive
:nnoremap <leader>g    :Git<cr>

"Switch to last file
:nnoremap <leader>l    :e #<cr>

"Switch between preview and main
:nnoremap <leader>p    <c-w>p 

"Quit
:nnoremap <leader>q   :q<cr>

"reload vimrc
:nnoremap <leader>r   :so $MYVIMRC<cr>

"remove spaces at the end of lines
:nnoremap <leader>s    :%s/\s\+$//<cr>

"Save
:nnoremap <leader>w   :w<cr>

:nnoremap <S-j>       <nop> 
:nnoremap <S-k>       <nop> 
:nnoremap <S-l>       <nop> 
:nnoremap <S-h>       <nop> 
:nnoremap <Up>        <nop>
:nnoremap <Down>      <nop>
:nnoremap <Right>     <nop>
:nnoremap <Left>      <nop>
"----------------------------------------
:inoremap <c-d>    <esc>ddi
:inoremap <c-u>    <esc>vwUi
:inoremap <c-z>    <esc>ui
" Autocomplete
:inoremap <c-c>    <C-x><C-o> 
:inoremap jk       <esc>

:hi Type           ctermfg=green ctermbg=none cterm=bold
:hi Folded         ctermfg=gray  ctermbg=none
:hi Search         cterm=NONE    ctermfg=black ctermbg=white

