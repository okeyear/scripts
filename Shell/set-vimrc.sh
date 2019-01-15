#!/bin/bash

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:$PATH
export PATH

stty erase ^H

function set::vimrc(){
cat > ~/.vimrc  <<- EOF
" inoremap ( ()<ESC>i
" inoremap [ []<ESC>i
" inoremap { {}<ESC>i
" inoremap < <><ESC>i
set autoindent
filetype on                 
set statusline=
set statusline+=%7*\[%n]                                  "buffernr
set statusline+=%2*\ %<%F\                                "File+path
set statusline+=%8*\ %y\                                  "FileType
set statusline+=%1*\ %{(&fenc!=''?&fenc:&enc)}      "Encoding
set statusline+=%1*\ %{(&bomb?\",BOM\":\"\")}\            "Encoding2
set statusline+=%4*\ %{&ff}\                              "FileFormat (dos/unix..) 
set statusline+=%5*\ %{&spelllang}\%{HighlightSearch()}\  "Spellanguage & Highlight on?
set statusline+=%3*\ %=\ row:%l/%L\ (%03p%%)\             "Rownumber/total (%)
set statusline+=%9*\ col:%03c\                            "Colnr
set statusline+=%1*\ \ %m%r%w\ %P\ \                      "Modified? Readonly? Top/bot.
function! HighlightSearch()
  if &hls
    return 'H'
  else
    return ''
  endif
endfunction
hi User1 guifg=#ffdad8  guibg=#880c0e cterm=none ctermfg=0 ctermbg=2 gui=none
hi User2 guifg=#000000  guibg=#F4905C cterm=none ctermfg=7 ctermbg=1 gui=none
hi User3 guifg=#292b00  guibg=#f4f597 cterm=none ctermfg=lightmagenta ctermbg=black gui=none
hi User4 guifg=#112605  guibg=#aefe7B cterm=none ctermfg=0 ctermbg=4 gui=none
hi User5 guifg=#051d00  guibg=#7dcc7d cterm=none ctermfg=white ctermbg=lightmagenta gui=none
hi User7 guifg=#ffffff  guibg=#880c0e cterm=none ctermfg=brown ctermbg=7 gui=bold 
hi User8 guifg=#ffffff  guibg=#5b7fbb cterm=none ctermfg=white ctermbg=3 gui=none
hi User9 guifg=#ffffff  guibg=#810085 cterm=none ctermfg=black ctermbg=lightcyan gui=none
set nocompatible               
filetype plugin indent on   
filetype plugin on 
set laststatus=2 
set cmdheight=2
set fencs=utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936
set history=1000
set tabstop=4 
set shiftwidth=4 
set softtabstop=4    
set novisualbell 
syntax on 
set confirm
set clipboard+=unnamed
set autoread   
set cursorcolumn 
set cursorline 
highlight CursorLine  cterm=NONE ctermbg=black ctermfg=green guibg=NONE guifg=NONE
highlight CursorColumn cterm=NONE ctermbg=black ctermfg=green guibg=NONE guifg=NONE

set iskeyword+=_,$,@,%,#,-
set t_ti= t_te= 
 set title " change the terminal's title 
set showmode 
set scrolloff=5 
set backspace=eol,start,indent
set whichwrap+=<,>,h,l 
set showmatch 
set matchtime=5
set nobackup
setlocal noswapfile
set bufhidden=hide
set linespace=0
set wildmenu
set hlsearch 
set incsearch 
set ignorecase 
set smartcase 
set showmatch
set foldenable 
set foldmethod=syntax
set foldlevel=100
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>
set report=0
set noerrorbells
autocmd! bufwritepost .vimrc source %
if has("autocmd")
  au BufReadPost * if line("'\"") > 1 && line("'\"") <= line("$") | exe "normal! g'\"" | endif
endif
nnoremap <silent> <F2>    :set nu!<CR> 
nnoremap <F3> :set list! list?<CR>
nnoremap <F4> :set wrap! wrap?<CR>
nnoremap <F5> :set paste! paste?<CR>
nnoremap <F6> :exec exists('syntax_on') ? 'syn off' : 'syn on'<CR>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
autocmd FileType python set tabstop=4 shiftwidth=4 expandtab ai
autocmd FileType ruby,javascript,html,css,xml set tabstop=2 shiftwidth=2 softtabstop=2 expandtab ai
autocmd BufRead,BufNewFile *.md,*.mkd,*.markdown set filetype=markdown.mkd
autocmd BufRead,BufNewFile *.part set filetype=html
au BufWinEnter *.php set mps-=<:>
fun! <SID>StripTrailingWhitespaces()
    let l = line(".")
    let c = col(".")
    %s/\s\+$//e
    call cursor(l, c)
endfun
autocmd FileType c,cpp,java,go,php,javascript,puppet,python,rust,twig,xml,yml,perl autocmd BufWritePre <buffer> :call <SID>StripTrailingWhitespaces()
if has("autocmd")
  " Highlight TODO, FIXME, NOTE, etc.
  if v:version > 701
    autocmd Syntax * call matchadd('Todo',  '\W\zs\(TODO\|FIXME\|CHANGED\|DONE\|XXX\|BUG\|HACK\)')
    autocmd Syntax * call matchadd('Debug', '\W\zs\(NOTE\|INFO\|IDEA\|NOTICE\)')
  endif
endif
autocmd BufNewFile *.py,*.cc,*.sh,*.java exec ":call SetTitle()"                                                                                               
function! SetTitle()  
         if &filetype == 'sh'  
                call setline(1, "\#!/bin/bash")  
                call setline(2, "\# ---------------------------------------------------------")  
                call setline(3, "\# Author: PengRuifang  &&  qq383326308  && okeyear@163.com")  
                call setline(4, "\# Created Time : ".strftime("%F %T"))  
                call setline(5, "\# Last Modified:   ") 
                call setline(6, "\# File Name: ".expand("%"))  
                call setline(7, "\# Revision:   ")  
                call setline(8, "\# Description:   ")  
                call setline(9, "\# Notes:  ")  
                call setline(10, "\# ---------------------------------------------------------")  
                call setline(11, "\# http://sysad.win   Copyleft:  (c) ")  
                call setline(12, "\# License:   ")  
                normal G
        endif  
        if &filetype == 'python'  
                call setline(1, "\#!/usr/bin/env python")  
                call setline(2, "\# coding=utf8")  
                call setline(3, "\# Author: PengRuifang  &&  qq383326308  && okeyear@163.com")  
                call setline(4, "\# Created Time : ".strftime("%F %T"))  
                call setline(5, "\# Last Modified: ") 
                call setline(6, "\# File Name: ".expand("%"))  
                call setline(7, "\# Revision:   ")  
                call setline(8, "\# Description:   ")  
                call setline(9, "\# Notes:   ")  
                call setline(10, "\# ---------------------------------------------------------")  
                call setline(11, "\# http://sysad.win   Copyleft:  (c)  ")  
                call setline(12, "\# License:   ")  
                normal G
        endif  
        if &filetype == 'java'  
                call setline(1, "//coding=utf8")  
                call setline(2, "/*************************************************************************") 
                call setline(3, "\ @Author: PengRuifang  &&  qq383326308  && okeyear@163.com")  
                call setline(4, "\ @Created Time : ".strftime("%F %T"))  
               call setline(5, "\ @Last Modified: ") 
                call setline(6, "\ @File Name: ".expand("%"))  
                call setline(7, "\ @Description:")  
                call setline(8, "\ @http://sysad.win   Copyleft:  (c)")  
                call setline(9, " ************************************************************************/") 
                call setline(10,"")  
        normal G
        endif  
endfunction 
function! SetLastModifiedTime()
        let modif_time = strftime("%F %T")
        let line = getline(5)
        if line =~ '^#\sLast Modified'                                                                         
                let line = '# Last Modified: '.modif_time
                call setline(5, line)
        else
                let line = '# Last Modified: '.modif_time
                call append(4, line)
        endif
endfunction                 
autocmd BufWrite,BufWritePre,FileWritePre *.py,*.java,*.sh call  SetLastModifiedTime() 
EOF
}