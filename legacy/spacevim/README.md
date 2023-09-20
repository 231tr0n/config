Add these contents in the init.vim or .vimrc file at the last

```vim
au CursorMovedI,BufEnter *.go,*.js,*.py,*.java,*.c,*.cpp,*.fish,*.bash,*.html,*.rs,*.rb syntax region hicurlybraces matchgroup=AllBraces start=/{/ end=/}/ contains=TOP
au CursorMovedI,BufEnter *.go,*.js,*.py,*.java,*.c,*.cpp,*.fish,*.bash,*.html,*.rs,*.rb syntax region hiparenthesis matchgroup=AllBraces start=/(/ end=/)/ contains=TOP
au CursorMovedI,BufEnter *.go,*.js,*.py,*.java,*.c,*.cpp,*.fish,*.bash,*.html,*.rs,*.rb syntax region hisquarebraces matchgroup=AllBraces start=/\[/ end=/\]/ contains=TOP
highlight AllBraces guifg=#ffaf00 guibg=NONE gui=NONE
```
