#!/bin/bash
export PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export LANG=en
set -e
sudo tee ~/.vimrc  <<EOF
""""""""""设定默认编码""""""""
set fencs=utf-8,ucs-bom,shift-jis,gb18030,gbk,gb2312,cp936
set termencoding=utf-8
set encoding=utf-8
set fileencodings=ucs-bom,utf-8,cp936
set history=1000

""""""""""" tab相关变更 """"""
" 设置Tab键的宽度        [等同的空格个数] 
set tabstop=4 
" 每一次缩进对应的空格数 
set shiftwidth=4 
" 按退格键时可以一次删掉 4 个空格 
set softtabstop=4    

""""""""""底部状态栏""""""""""""""""""""
"Format the statusline
" Always show the status line - use 2 lines for the status bar 
set laststatus=2 

" 命令行（在状态行下）的高度，默认为1，这里是2
set cmdheight=2
filetype on                  "  检测文件类型

" Nice statusbar
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

" set statusline+=%F%m%r%h%w
" set statusline+=[%{strftime(\"%Y-%m-%d\ %H:%M\")}] " time
" Highlight on? function:

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
EOF
