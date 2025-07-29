call plug#begin()
Plug 'ryanoasis/vim-devicons'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'preservim/nerdtree' |
            \ Plug 'Xuyuanp/nerdtree-git-plugin'
" Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'github/copilot.vim'
" Plug 'mhinz/vim-startify'
Plug 'sheerun/vim-polyglot'
Plug 'tpope/vim-commentary'
Plug 'nvim-lua/plenary.nvim'
" Plug 'frazrepo/vim-rainbow'
Plug 'nvim-telescope/telescope.nvim'
" Plug 'jiangmiao/auto-pairs'
" Plug 'bagrat/vim-buffet'
" Plug 'dense-analysis/ale'
" Plug 'vimsence/vimsence'
call plug#end()

"rainbow 
" au FileType c,cpp,objc,objcpp call rainbow#load()
" let g:rainbow_active = 1

" terminal start insert
autocmd TermOpen * startinsert
augroup custom_term
	autocmd!
	autocmd TermOpen * setlocal nonumber norelativenumber bufhidden=hide
augroup END

" last position
if has("autocmd")
  au BufReadPost * if line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g'\"" | endif
endif

" copy templates
autocmd filetype cpp nnoremap <F1> :r $HOME/Code/competitive-programming/CodeTemplates/cpp_singletest.cpp <Return> kdd :12 <Return> o
autocmd filetype cpp nnoremap <F2> :r $HOME/Code/competitive-programming/CodeTemplates/cpp_multitest.cpp <Return> kdd :12 <Return> o
autocmd filetype cpp nnoremap <F9> :%s/TC = 1/TC = 0<Return> gg :13 <Return>
autocmd filetype cpp nnoremap <F10> :%s/TC = 0/TC = 1<Return> gg :13 <Return>
autocmd filetype c nnoremap <F1> :r $HOME/Code/competitive-programming/CodeTemplates/cdefault.c <Return> kdd :4 <Return> o

" Filetypes autocmds to compile and run
autocmd filetype python nnoremap <F4> :w <bar> term s '%' <CR>
autocmd filetype c nnoremap <F4> :w <bar> term s '%' <CR>
autocmd filetype haskell nnoremap <F4> :w <bar> term ghci '%' <CR>

autocmd filetype cpp nnoremap <F4> :w <bar> term s '%' <CR>
autocmd filetype cpp nnoremap <F5> :w <bar> term s '%' -f <CR>
autocmd filetype cpp nnoremap <F6> :w <bar> term s '%' -f -std 17 <CR>
autocmd filetype cpp nnoremap <F7> :w <bar> term s '%' -f -std 11 <CR>
autocmd filetype cpp nnoremap <F8> :w <bar> term run '%' <CR>

" GENERAL SETTINGS
"leader 
let mapleader = ","

" Appearance
set notermguicolors
color vim
" set cursorline
set number
" set relativenumber
" hi Normal ctermbg=NONE guibg=NONE
" cursor
set guicursor=i:block


" Blink cursor on error instead of beeping
set belloff=all

" Encoding
set encoding=UTF-8

" Whitespace
set wrap
set textwidth=90
set formatoptions=tcqrn1
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab
set noshiftround

" Allow hidden buffers
set hidden
set noautowrite

" Rendering
set ttyfast

" Status bar
set laststatus=0
let s:hidden_all = 0
function! ToggleHiddenAll()
    if s:hidden_all  == 0
        let s:hidden_all = 1
        set noshowmode
        set noruler
        set laststatus=0
        set noshowcmd
    else
        let s:hidden_all = 0
        set showmode
        set ruler
        set laststatus=2
        set showcmd
    endif
endfunction

nnoremap <S-h> :call ToggleHiddenAll()<CR>

" Searching
set nohlsearch
set incsearch
set ignorecase
set smartcase

" New lines not commented
autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

set scrolloff=10

"mouse support
set mouse=a

" change working directory
autocmd BufEnter * if expand("%:p:h") !~ '^/cdrom' | silent! lcd %:p:h | endif

" Turn on syntax highlighting
syntax on

" remaps
inoremap <C-s> <esc> :w <CR>
nnoremap <C-s> :w <CR>
nnoremap <C-d> :x <CR>
" conserta as chaves do eric
" nnoremap Ç :g/{/normal kJx <CR>
" nnoremap ç :g/{/normal $xo{ <CR>
inoremap {} {}<left><return><up><end><return>
set history=5000
set undofile

" nerd tree
nnoremap <leader>t <cmd>:NERDTree<CR>
nnoremap <leader>n <cmd>:NERDTreeToggle<CR>
nnoremap <leader>f <cmd>:NERDTreeFind<CR>
" open NERDTree automatically
" autocmd StdinReadPre * let s:std_in=1
" autocmd VimEnter * NERDTree

let g:NERDTreeGitStatusWithFlags = 1
"let g:WebDevIconsUnicodeDecorateFolderNodes = 1
"let g:NERDTreeGitStatusNodeColorization = 1
"let g:NERDTreeColorMapCustom = {
    "\ "Staged"    : "#0ee375",  
    "\ "Modified"  : "#d9bf91",  
    "\ "Renamed"   : "#51C9FC",  
    "\ "Untracked" : "#FCE77C",  
    "\ "Unmerged"  : "#FC51E6",  
    "\ "Dirty"     : "#FFBD61",  
    "\ "Clean"     : "#87939A",   
    "\ "Ignored"   : "#808080"   
    "\ }                         


let g:NERDTreeIgnore = ['^node_modules$']


" COC
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gr <Plug>(coc-references)
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nnoremap <silent> <space>s :<C-u>CocList -I symbols<cr>
nnoremap <silent> <space>d :<C-u>CocList diagnostics<cr>
nmap <leader>do <Plug>(coc-codeaction)
nmap <leader>rn <Plug>(coc-rename)


" Buffet
nmap <leader>1 <Plug>BuffetSwitch(1)
nmap <leader>2 <Plug>BuffetSwitch(2)
nmap <leader>3 <Plug>BuffetSwitch(3)
nmap <leader>4 <Plug>BuffetSwitch(4)
nmap <leader>5 <Plug>BuffetSwitch(5)
nmap <leader>6 <Plug>BuffetSwitch(6)
nmap <leader>7 <Plug>BuffetSwitch(7)
nmap <leader>8 <Plug>BuffetSwitch(8)
nmap <leader>9 <Plug>BuffetSwitch(9)
nmap <leader>0 <Plug>BuffetSwitch(10)
noremap <Tab> :bn<CR>
noremap <S-Tab> :bp<CR>
noremap <Leader><Tab> :Bw<CR>
noremap <Leader><S-Tab> :Bw!<CR>
" let g:buffet_powerline_separators = 1
let g:buffet_show_index = 1
let g:buffet_use_devicons = 1
" function! g:BuffetSetCustomColors()
"   hi! BuffetCurrentBuffer cterm=NONE ctermbg=2 ctermfg=0 guibg=#000000 guifg=#000000
" endfunction

" ale
" let g:ale_cpp_cc_options = '-std=c++20 -Wshadow -Wconversion -O2 -Wfatal-errors -Wall -Wextra -Wno-unused-result -Wno-unused-variable -fsanitize=address -fsanitize=undefined -fno-sanitize-recover -Wformat=2 -Wfloat-equal -Wshift-overflow -Wcast-qual -Wcast-align'
" let g:ale_linters = {
"     \ 'cpp': ['clang'],
" \}
" let g:ale_lint_on_save = 1
" let g:ale_lint_on_enter = 1 
" let g:ale_lint_on_insert_leave = 1
" let g:ale_virtualtext_cursor = 'disabled'


" Copilot
" let g:copilot_filetypes = {
"             \ '*': v:false,
"             \ }


" Define a custom command to open the Telescope picker in the ~/tpl folder
command! -nargs=0 TplPicker lua require('telescope.builtin').find_files({ prompt_title = 'Library Files', cwd = '~/Code/competitive-programming/Library', hidden = true })<CR>
" Create a custom key mapping to trigger the TPL picker
nnoremap <leader>l :TplPicker<CR>
" nnoremap <leader>y :execute 'normal! ggVG"xy'<CR>:b#<CR>
nnoremap <leader>p :let @" = join(getline(1, '$'), "\n")<CR>:b#<CR>p`[<CR>

"Last line
set showmode
set showcmd
