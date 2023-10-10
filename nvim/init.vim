set encoding=utf-8
scriptencoding utf-8
" Keep in mind that Meta key combinations dont work in gnome terminal and so all mappings should be with Meta key combinations
" functions
function SynGroup()
  if !exists("*synstack")
    return
  endif
  echo map(synstack(line('.'), col('.')), 'synIDattr(v:val, "name")')
endfun
" print syntax group of the character under cursor
function <SID>StripTrailingWhitespaces()
  let l=line(".")
  let c=col(".")
  %s/\s\+$//e
  call cursor(l, c)
endfunction
" function FileBrowserToggle()
"   if winnr('$')==1
"     call feedkeys(":Vexplore\<CR>")
"   elseif winnr('$')==2
"     call feedkeys("\<C-w>h:q\<CR>")
"   endif
" endfunction
function FileBrowserToggle()
  if !exists("t:NetrwIsOpen")
    let t:NetrwIsOpen=0
  endif
  if t:NetrwIsOpen
    let i = bufnr("$")
    while (i >= 1)
      if (getbufvar(i, "&filetype") == "netrw")
        silent exe "bwipeout " . i
      endif
      let i-=1
    endwhile
    let t:NetrwIsOpen=0
  else
    let t:NetrwIsOpen=1
    silent Lexplore
  endif
endfunction
" toggle filebrowser
function StatuslineModeColorReturner()
  if mode()[0]==?'R'
    return '%#ReplaceMode#%'
  elseif mode()[0]==?'n'
    return '%#NormalMode#%'
  elseif mode()[0]==?'i'
    return '%#InsertMode#%'
  elseif mode()[0]==#'v'
    return '%#VisualMode#%'
  elseif mode()[0]==#'V'
    return '%#VisualMode#%'
  elseif stridx(mode(), "\<C-V>") >= 0
    return '%#VisualMode#%'
  elseif mode()[0]==?'s' || (stridx(mode(), "\<C-S>") >= 0)
    return '%#SelectMode#%'
  elseif mode()[0]==?'c'
    return '%#CommandMode#%'
  endif
  return '%#DefaultMode#%'
endfunction
" returns color for statusline mode
function StatuslineModeReturner()
  if mode()[0]==?'R'
    return StatuslineModeColorReturner() . '\ REPLACE '
  elseif mode()[0]==?'n'
    return StatuslineModeColorReturner() . '\ NORMAL '
  elseif mode()[0]==?'i'
    if &paste == 1
      return StatuslineModeColorReturner() . '\ P-INSERT '
    endif
    return StatuslineModeColorReturner() . '\ INSERT '
  elseif mode()[0]==#'v'
    return StatuslineModeColorReturner() . '\ VISUAL '
  elseif mode()[0]==#'V'
    return StatuslineModeColorReturner() . '\ V-LINE '
  elseif stridx(mode(), "\<C-V>") >= 0
    return StatuslineModeColorReturner() . '\ V-BLOCK '
  elseif mode()[0]==?'s' || stridx(mode(), "\<C-S>") >= 0
    return StatuslineModeColorReturner() . '\ SELECT '
  elseif mode()[0]==?'c'
    return StatuslineModeColorReturner() . '\ COMMAND '
  endif
  return StatuslineModeColorReturner() . '\ ' . mode() . ' '
endfunction
" returns which mode vim is in for statusline
function CheckActiveWindow()
  if g:actual_curwin==win_getid()
    return '@'
  else
    return '#'
  endif
endfunction
" check if the window is active

" key mappings
inoremap <silent> { {}<Left>
" { - {|}
inoremap <silent> ( ()<Left>
" ( - (|)
inoremap <silent> [ []<Left>
" [ - [|]
inoremap <silent> " ""<Left>
" " - "|"
inoremap <silent> ' ''<Left>
" ' - '|'
inoremap <silent> ` ``<Left>
" ` - `|`
inoremap <silent> {} {}
" {} - {}|
inoremap <silent> () ()
" () - ()|
inoremap <silent> [] []
" [] - []|
inoremap <silent> {<Tab> {}
" {\t - {}|
inoremap <silent> (<Tab> ()
" (\t - ()|
inoremap <silent> [<Tab> []
" [\t - []|
inoremap <silent> "" ""
" "" - ""|
inoremap <silent> '' ''
" '' - ''|
inoremap <silent> `` ``
" `` - ``|
inoremap <silent> {<Space> {
" {\s - {|
inoremap <silent> (<Space> (
" (\s - (|
inoremap <silent> [<Space> [
" [\s - [|
inoremap <silent> "<Space> "
" "\s - "|
inoremap <silent> '<Space> '
" '\s - '|
inoremap <silent> `<Space> `
" `\s - `|
nnoremap <silent> <Tab><Tab><Tab> :set noet\|retab!<CR>
" \t\t\t - convert spaces to tabs
nnoremap <silent> <Space><Space><Space> :set et\|retab<CR>
" \s\s\s - convert tabs to spaces
nnoremap find1 :1,$s/  /\t/g
" replace regex for strings with special characters
nnoremap find2 :n1,n2s///g
" replace regex for strings from n1 to n2
nnoremap find3 :%s///g
" replace regex for strings for whole file
nnoremap <Tab>c :tabnew<Space>
" create new tab
nnoremap <Tab>n :tabn<Space>
" go to the tab with the number specified
nnoremap <silent> <Tab><up> :tabr<CR>
nnoremap <silent> <Tab>k :tabr<CR>
" go to the first tab
nnoremap <silent> <Tab><down> :tabl<CR>
nnoremap <silent> <Tab>j :tabl<CR>
" go to the last tab
nnoremap <silent> <Tab><left> :tabp<CR>
nnoremap <silent> <Tab>h :tabp<CR>
" go to the previous tab
nnoremap <silent> <Tab><right> :tabn<CR>
nnoremap <silent> <Tab>l :tabn<CR>
" go to the next tab
nnoremap <F7><F7> :split<Space>
" create a horizontal split in vim
nnoremap <F7> :vsplit<Space>
" create a vertical split in vim
vnoremap <silent> <C-c> "+y
vnoremap <silent> <C-x> "+d
" cut and copy text to system clipboard
nnoremap <silent> <F6> :setl wrap!<CR>
inoremap <silent> <F6> <Esc>:setl wrap!<CR>a
" toggle wrap
nnoremap <silent> <F5> :nohl<CR>
inoremap <silent> <F5> <Esc>:nohl<CR>a
" remove highlighting done by search regex
inoremap <silent> <C-h> <left>
inoremap <silent> <C-j> <down>
inoremap <silent> <C-k> <up>
inoremap <silent> <C-l> <right>
" navigating in insert mode
nnoremap <silent> <F1> :pclose
inoremap <silent> <F1> <Esc>:pclose<CR>a
" closes all kinds of preview windows
nnoremap <silent> <F2> :call FileBrowserToggle()<CR>
inoremap <silent> <F2> <Esc>:call FileBrowserToggle()<CR>a
" toggles file browser
nnoremap <silent> <F10> :call SynGroup()<CR>
inoremap <silent> <F10> <Esc>:call SynGroup()<CR>a
" make background nontransparent.
nnoremap <silent> <F11> :highlight Normal ctermbg=235<CR>
" prints the highlight group of the character under the cursor
" Filetype maps
au FileType html,xml,xsl inoremap <silent> <C-_> <Esc>A<Enter></<C-x><C-o><Esc>O<Tab>
" <html>| or <html|> - <html>\n\t|\n</html>
au FileType html,xml,xsl inoremap <silent> <C-_><C-_> <Esc>F<f>a</<C-x><C-o><Esc>vit<Esc>i
" <html|> - <html>|</html>
au FileType html,xml,xsl inoremap <silent> <C-_><C-_><C-_> <Esc>F<f>a</<C-x><C-o>
" <html|> - <html></html>|
au FileType html,xml,xsl inoremap <silent> < <><Left>
" < - <|>
au FileType html,xml,xsl inoremap <silent> </ </><Left>
" </ - </|>
au FileType html,xml,xsl inoremap <silent> <% <%<Space><Space>%><Left><Left><Left>
" <% - <% | %>
au FileType html,xml,xsl inoremap <silent> <%= <%=<Space><Space>%><Left><Left><Left>
" <%= - <%= | %>
au FileType html,xml,xsl inoremap <silent> <> <>
" <> - <>|
au FileType html,xml,xsl inoremap <silent> </> </>
" </> - </>|
au FileType html,xml,xsl inoremap <silent> <%<Space> <%
" <%\s - <%|
au FileType html,xml,xsl inoremap <silent> <%=<Space> <%=
" <%=\s - <%|
au FileType html,xml,xsl inoremap <silent> <<Space> <
" <\s - <|
au FileType html,xml,xsl inoremap <silent> </<Space> </
" </\s - </|
au FileType html,xml,xsl inoremap <silent> <%=<Space><Space>%> <%=<Space><Space>%>
" <%=  %> - <%=  %>|
au FileType html,xml,xsl inoremap <silent> <%<Space><Space>%> <%<Space><Space>%>
" <%  %> - <%  %>|
au BufEnter *.js,*.ejs,*.html imap <silent> =<CR> =><Space>{<CR>
" = - <Space>=><Space>{\n\t|\n}
au BufEnter *.py,*.fish,*.sh,*.bash,*.ruby vnoremap <silent> <F3> :norm<Space>^i#<Space><CR>
au FileType sh vnoremap <silent> <F3> :norm<Space>^i#<Space><CR>
au BufEnter *.php,*.js,*.c,*.cpp,*.java,*.scala,*.go vnoremap <silent> <F3> :norm<Space>^i//<Space><CR>
au BufEnter *.vim,.vimrc vnoremap <silent> <F3> :norm<Space>^i"<Space><Space><CR>
au BufEnter *.py,*.fish,*.sh,*.bash,*.ruby nnoremap <silent> <F3> :norm<Space>^i#<Space><CR>
au FileType sh nnoremap <silent> <F3> :norm<Space>^i#<Space><CR>
au BufEnter *.php,*.js,*.c,*.cpp,*.java,*.scala,*.go nnoremap <silent> <F3> :norm<Space>^i//<Space><CR>
au BufEnter *.vim,.vimrc nnoremap <silent> <F3> :norm<Space>^i"<Space><Space><CR>
au BufEnter *.py,*.fish,*.sh,*.bash,*.ruby inoremap <silent> <F3> <Esc>:norm<Space>^i#<Space><CR>i
au FileType sh inoremap <silent> <F3> <Esc>:norm<Space>^i#<Space><CR>i
au BufEnter *.php,*.js,*.c,*.cpp,*.java,*.scala,*.go inoremap <silent> <F3> <Esc>:norm<Space>^i//<Space><CR>i
au BufEnter *.vim,.vimrc inoremap <silent> <F3> <Esc>:norm<Space>^i"<Space><Space><CR>i
au BufEnter *.py,*.fish,*.sh,*.bash,*.ruby vnoremap <silent> <F4> :norm<Space>^xx<Space><CR>
au FileType sh vnoremap <silent> <F4> :norm<Space>^xx<Space><CR>
au BufEnter *.php,*.js,*.c,*.cpp,*.java,*.scala,*.go vnoremap <silent> <F4> :norm<Space>^xxx<Space><CR>
au BufEnter *.vim,.vimrc vnoremap <silent> <F4> :norm<Space>^xx<Space><CR>
au BufEnter *.py,*.fish,*.sh,*.bash,*.ruby nnoremap <silent> <F4> :norm<Space>^xx<Space><CR>
au FileType sh vnoremap <silent> <F4> :norm<Space>^xx<Space><CR>
au BufEnter *.php,*.js,*.c,*.cpp,*.java,*.scala,*.go nnoremap <silent> <F4> :norm<Space>^xxx<Space><CR>
au BufEnter *.vim,.vimrc nnoremap <silent> <F4> :norm<Space>^xx<Space><CR>
au BufEnter *.py,*.fish,*.sh,*.bash,*.ruby inoremap <silent> <F4> <Esc>:norm<Space>^xx<Space><CR>i
au FileType sh inoremap <silent> <F4> <Esc>:norm<Space>^xx<Space><CR>i
au BufEnter *.php,*.js,*.c,*.cpp,*.java,*.scala,*.go inoremap <silent> <F4> <Esc>:norm<Space>^xxx<Space><CR>i
au BufEnter *.vim,.vimrc inoremap <silent> <F4> <Esc>:norm<Space>^xx<Space><CR>i
" Used to put comments in a file.

" auto commands
au FileType netrw setl statusline=#
au FileType netrw setl nolist
au FileType netrw vertical resize 25
au FileType netrw setl signcolumn=no
au BufEnter *.svelte set filetype=html
" removes list and statusline for netrw buffers
au BufWritePre * call <SID>StripTrailingWhitespaces()
" strips trailing whitespaces
au BufWritePre * :%s#\($\n\s*\)\+\%$##e
" removes empty lines at the last of the file
au ModeChanged * redrawstatus
au CmdlineEnter * redrawstatus
au CmdlineLeave * redrawstatus
" updates statusline whenever mode is changed or commandline is entered
" au InsertEnter,InsertCharPre * call feedkeys("\<C-p>\<C-n>")
" open wildmenu in insert mode automatically
au WinEnter * if winnr('$') == 1 && getbufvar(winbufnr(winnr()), "&filetype") == "netrw"|q|endif
" closes vim if filemanager is the only window remaining

" filetype settings
au BufEnter *.ejs set filetype=html
" sets html filetype for ejs templates
au BufEnter *.fish set filetype=sh
" sets sh filetype for fish files
au BufEnter *.txt set wrap
let g:python_recommended_style=0
" Disables Python style for indentation guides
" sets wrap for text files.
filetype on
filetype plugin on
filetype indent off
" filetype plugin indent off
" filetype plugins and indent off

" options
" set spell
" enables spell
set gp=git\ grep\ -n
" search commands
" set ignorecase
" ignorecase when searching
" set smartcase
" sets smartcase
set wildignore=*.exe,*.dll,*.pdb
" ignores extensions when autocompletiting
packadd! matchit
" config for plugin files
set backspace=2
" makes backspace normal
set conceallevel=2
" sets conceallevel to 2
set t_Co=256
" redraw
" redraw's vim screen
" sets colors to 256
" set termguicolors
" sets colors to true colors
set mouse=a
" sets mouse mode to on
set nocompatible
" removes compatibility with vi
set encoding=utf-8
" sets encoding to utf-8
set nobackup
set nowritebackup
" disables backup
syntax on
" sets syntax on
set showmatch
" shows all matches of a word like bash
set matchpairs+=<:>
set title
" sets title
set number
" sets numberline for the text editor
set laststatus=2
" sets statusline
set cursorcolumn
" highlights the vertical line in which the cursor is
set cursorline
" highlights the horizontal line in which the cursor is
set incsearch
" starts searching for the word when you enter the first character of the string
set hlsearch
" setting searchlist
set wildmenu
set wildmode=longest:full,full
" setting wildmenu
set list
" set invisible characters
set autoindent
" puts your cursor on the same indentation level as the before line
set nowrap
" removes wordwrap in vim
set noexpandtab
" sets tabs instead of spaces
set tabstop=2
" sets tabspace
set shiftwidth=2
" sets the width to shift for the selected lines or line of text
set nofoldenable
" removes function folding by default
set foldmethod=indent
" set fold method to indentation
set pastetoggle=<F9>
" toggling paste mode on and off
set noshowmode
" removes showing the current mode of vim
tab all
" converts all files in argument list to tabs
syntax reset
" reset syntax
highlight clear
" clear custom highlighting
set background=dark
" Sets background to dark
set listchars=eol:¬,tab:\|\-,trail:~,extends:>,precedes:<
" set symbols for indents, and end of line characters.
set textwidth=0
" sets width of text to infinity
let g:netrw_banner=0
let g:netrw_liststyle=0
let g:netrw_browse_split=4
let g:netrw_altv=1
let g:netrw_winsize=25
let g:netrw_keepdir = 0
" netrw config

" autocompletition
set omnifunc=syntaxcomplete#Complete
au FileType html,xml,xsl set omnifunc=htmlcomplete#CompleteTags
" Builtin syntax completition
set completeopt=menuone,preview
" completition wildmenu settings

" colorscheme
highlight ColorColumn        ctermfg=NONE ctermbg=234  cterm=NONE
highlight Conceal            ctermfg=172  ctermbg=NONE cterm=NONE
highlight Cursor             ctermfg=0    ctermbg=10   cterm=NONE
highlight lCursor            ctermfg=10   ctermbg=NONE cterm=NONE
highlight CursorIM           ctermfg=0    ctermbg=10   cterm=NONE
highlight CursorColumn       ctermfg=NONE ctermbg=234  cterm=NONE
highlight CursorLine         ctermfg=NONE ctermbg=234  cterm=NONE
highlight Directory          ctermfg=67   ctermbg=NONE cterm=NONE
highlight DiffAdd            ctermfg=2    ctermbg=17   cterm=NONE
highlight DiffDelete         ctermfg=9    ctermbg=17   cterm=NONE
highlight DiffChange         ctermfg=12   ctermbg=17   cterm=NONE
highlight DiffText           ctermfg=10   ctermbg=88   cterm=NONE
" highlight EndOfBuffer
highlight ErrorMsg           ctermfg=0    ctermbg=167  cterm=NONE
" highlight VertSplit          ctermfg=235  ctermbg=238  cterm=NONE
highlight VertSplit          ctermfg=234  ctermbg=NONE cterm=NONE
highlight Folded             ctermfg=133  ctermbg=236  cterm=NONE
highlight FoldColumn         ctermfg=67   ctermbg=236  cterm=NONE
" highlight SignColumn         ctermfg=118  ctermbg=235  cterm=NONE
highlight SignColumn         ctermfg=118  ctermbg=NONE cterm=NONE
highlight IncSearch          ctermfg=0    ctermbg=28   cterm=NONE
highlight LineNr             ctermfg=8    ctermbg=234  cterm=NONE
" highlight LineNrAbove
" highlight LineNrBelow
highlight CursorLineNR       ctermfg=0    ctermbg=8    cterm=NONE
" highlight CursorLineSign
" highlight CursorLineFold
highlight MatchParen         ctermfg=0    ctermbg=130  cterm=NONE
" highlight MessageWindow
highlight ModeMsg            ctermfg=229  ctermbg=NONE cterm=NONE
" highlight MoreMsg
highlight NonText            ctermfg=240  ctermbg=NONE cterm=NONE
" highlight Normal             ctermfg=249  ctermbg=235  cterm=NONE
highlight Normal             ctermfg=249  ctermbg=NONE cterm=NONE
highlight Pmenu              ctermfg=141  ctermbg=236  cterm=NONE
highlight PmenuSel           ctermfg=141  ctermbg=238  cterm=NONE
highlight PmenuSbar          ctermfg=28   ctermbg=233  cterm=NONE
highlight PmenuThumb         ctermfg=160  ctermbg=97   cterm=NONE
" highlight PopupNotification
highlight Question           ctermfg=81   ctermbg=NONE cterm=NONE
" highlight QuickFixLine
highlight Search             ctermfg=0    ctermbg=28   cterm=NONE
" highlight CurSearch
highlight SpecialKey         ctermfg=240  ctermbg=NONE cterm=NONE
highlight SpellBad           ctermfg=15   ctermbg=NONE cterm=underline
highlight SpellCap           ctermfg=15   ctermbg=NONE cterm=underline
highlight SpellLocal         ctermfg=253  ctermbg=NONE cterm=underline
highlight SpellRare          ctermfg=218  ctermbg=NONE cterm=underline
highlight StatusLine         ctermfg=NONE ctermbg=233  cterm=NONE
highlight StatusLineNC       ctermfg=NONE ctermbg=234  cterm=NONE
highlight StatusLineTerm     ctermfg=140  ctermbg=238  cterm=NONE
highlight StatusLineTermNC   ctermfg=244  ctermbg=237  cterm=NONE
highlight TabLine            ctermfg=66   ctermbg=239  cterm=NONE
highlight TabLineFill        ctermfg=145  ctermbg=238  cterm=NONE
highlight TabLineSel         ctermfg=178  ctermbg=240  cterm=NONE
" highlight Terminal
highlight Title              ctermfg=176  ctermbg=NONE cterm=NONE
highlight Visual             ctermfg=NONE ctermbg=238  cterm=NONE
highlight VisualNOS          ctermfg=NONE ctermbg=238  cterm=NONE
highlight WarningMsg         ctermfg=0    ctermbg=100  cterm=NONE
highlight WildMenu           ctermfg=214  ctermbg=239  cterm=NONE
" Syntax
highlight Comment            ctermfg=30   ctermbg=NONE cterm=NONE
highlight Constant           ctermfg=218  ctermbg=NONE cterm=NONE
highlight String             ctermfg=36   ctermbg=NONE cterm=NONE
highlight Character          ctermfg=75   ctermbg=NONE cterm=NONE
highlight Number             ctermfg=176  ctermbg=NONE cterm=NONE
highlight Boolean            ctermfg=178  ctermbg=NONE cterm=NONE
highlight Float              ctermfg=135  ctermbg=NONE cterm=NONE
highlight Identifier         ctermfg=167  ctermbg=NONE cterm=NONE
highlight Function           ctermfg=169  ctermbg=NONE cterm=NONE
highlight Statement          ctermfg=68   ctermbg=NONE cterm=NONE
highlight Conditional        ctermfg=68   ctermbg=NONE cterm=NONE
highlight Repeat             ctermfg=68   ctermbg=NONE cterm=NONE
highlight Label              ctermfg=104  ctermbg=NONE cterm=NONE
highlight Operator           ctermfg=111  ctermbg=NONE cterm=NONE
highlight Keyword            ctermfg=68   ctermbg=NONE cterm=NONE
highlight Exception          ctermfg=204  ctermbg=NONE cterm=NONE
highlight PreProc            ctermfg=176  ctermbg=NONE cterm=NONE
highlight Include            ctermfg=176  ctermbg=NONE cterm=NONE
highlight Define             ctermfg=177  ctermbg=NONE cterm=NONE
highlight Macro              ctermfg=140  ctermbg=NONE cterm=NONE
highlight PreCondit          ctermfg=139  ctermbg=NONE cterm=NONE
highlight Type               ctermfg=68   ctermbg=NONE cterm=NONE
highlight StorageClass       ctermfg=178  ctermbg=NONE cterm=NONE
highlight Structure          ctermfg=68   ctermbg=NONE cterm=NONE
highlight Typedef            ctermfg=68   ctermbg=NONE cterm=NONE
highlight Special            ctermfg=169  ctermbg=NONE cterm=NONE
highlight SpecialChar        ctermfg=171  ctermbg=NONE cterm=NONE
highlight Tag                ctermfg=161  ctermbg=NONE cterm=NONE
highlight Delimiter          ctermfg=151  ctermbg=NONE cterm=NONE
highlight SpecialComment     ctermfg=24   ctermbg=NONE cterm=NONE
highlight Debug              ctermfg=225  ctermbg=NONE cterm=NONE
highlight Underlined         ctermfg=81   ctermbg=NONE cterm=underline
highlight Ignore             ctermfg=244  ctermbg=NONE cterm=NONE
highlight Error              ctermfg=0    ctermbg=167  cterm=NONE
highlight Todo               ctermfg=0    ctermbg=100  cterm=NONE
highlight Warning            ctermfg=0    ctermbg=100  cterm=NONE
" statusline highlighting
highlight User1              ctermfg=0    ctermbg=25   cterm=NONE
highlight User2              ctermfg=0    ctermbg=245  cterm=NONE
highlight User3              ctermfg=0    ctermbg=240  cterm=NONE
highlight User4              ctermfg=8    ctermbg=234  cterm=NONE
highlight User5              ctermfg=0    ctermbg=245  cterm=NONE
highlight User6              ctermfg=0    ctermbg=247  cterm=NONE
highlight NormalMode         ctermfg=0    ctermbg=25   cterm=NONE
highlight DefaultMode        ctermfg=0    ctermbg=25   cterm=NONE
highlight InsertMode         ctermfg=0    ctermbg=106  cterm=NONE
highlight VisualMode         ctermfg=0    ctermbg=169  cterm=NONE
highlight CommandMode        ctermfg=0    ctermbg=130  cterm=NONE
highlight SelectMode         ctermfg=0    ctermbg=28   cterm=NONE
highlight ReplaceMode        ctermfg=0    ctermbg=167  cterm=NONE
" custom highlight group group
highlight AllBraces          ctermfg=172  ctermbg=NONE cterm=NONE
" highlight AllExtraChars      ctermfg=214  ctermbg=NONE cterm=NONE
highlight link javaScript Normal
highlight link javaScriptBraces AllBraces

" custom regex for highlighting
au CursorMovedI,FileType sh syntax region hicurlybraces matchgroup=AllBraces start=/{/ end=/}/ contains=TOP
au CursorMovedI,FileType sh syntax region hiparenthesis matchgroup=AllBraces start=/(/ end=/)/ contains=TOP
au CursorMovedI,FileType sh syntax region hisquarebraces matchgroup=AllBraces start=/\[/ end=/\]/ contains=TOP
au CursorMovedI,BufEnter *.go,*.js,*.py,*.java,*.c,*.cpp,*.fish,*.bash,*.html,*.rs,*.rb syntax region hicurlybraces matchgroup=AllBraces start=/{/ end=/}/ contains=TOP
au CursorMovedI,BufEnter *.go,*.js,*.py,*.java,*.c,*.cpp,*.fish,*.bash,*.html,*.rs,*.rb syntax region hiparenthesis matchgroup=AllBraces start=/(/ end=/)/ contains=TOP
au CursorMovedI,BufEnter *.go,*.js,*.py,*.java,*.c,*.cpp,*.fish,*.bash,*.html,*.rs,*.rb syntax region hisquarebraces matchgroup=AllBraces start=/\[/ end=/\]/ contains=TOP
" highlight curlybraces, parenthesis and squarebraces
" syntax match Constant /0123456789/
" 2match AllExtraChars /[.~,?/\|:;!@#$%^&*\-+=]/
" match AllBraces /[(){}<>\[\]]/

" vim and nvim config
if has('nvim')
  " options
  set updatetime=300
  " updates swap file in 300ms
  set signcolumn=yes
  " open sign column by default
  set guicursor=n-v-c:block
  set guicursor+=i:ver100
  set guicursor+=r:ver100
  " sets cursor to a beam in insertmode and block in other modes. Works only for gnome-terminal

  filetype indent off
  " This is called becaused vim-plug turns on filetype indent.

  nnoremap <silent> <M-x> :pclose<CR>
  " closing panel in neovim

  " Standard key mappings
  inoremap <silent> :<CR> :<CR><Tab>
  " :\n - :\n\t
  inoremap <silent> {<CR> {<CR>}<Esc>O<Tab>
  " { - {\n\t|\n}
  inoremap <silent> (<CR> (<CR>)<Esc>O<Tab>
  " ( - (\n\t|\n)
  inoremap <silent> [<CR> [<CR>]<Esc>O<Tab>
  " [ - [\n\t|\n]

  " Plugin config

  " Plugins
  call plug#begin()
    Plug 'prabirshrestha/vim-lsp'
    Plug 'mattn/vim-lsp-settings'
    Plug 'prabirshrestha/asyncomplete.vim'
    Plug 'prabirshrestha/asyncomplete-lsp.vim'
    Plug 'junegunn/fzf'
    Plug 'junegunn/fzf.vim'
    Plug 'tpope/vim-fugitive'
  call plug#end()
  filetype indent off

  " Plugin post config
  function! s:on_lsp_buffer_enabled() abort
    setlocal omnifunc=lsp#complete
    nmap <buffer> <M-i> <plug>(lsp-definition)
    nmap <buffer> <M-d> <plug>(lsp-declaration)
    nmap <buffer> <M-r> <plug>(lsp-references)
    nmap <buffer> <M-l> <plug>(lsp-document-diagnostics)
    nmap <buffer> <M-r> <plug>(lsp-rename)
    nmap <buffer> <M-h> <plug>(lsp-hover)
    let g:lsp_format_sync_timeout = 1000
    autocmd! BufWritePre *.rs,*.go call execute('LspDocumentFormatSync')
  endfunction

  augroup lsp_install
    au!
    autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
  augroup END

  " auto commands
  " au FileType python quit
  " makes us not use nvim for python files
  " au VimEnter * call FileBrowserToggle() | call feedkeys("\<C-w>l")
  " open filebrowser by default

  " statusline
  set statusline=%{%StatuslineModeReturner()%}
  set statusline+=%2*\ %Y\ %*
  set statusline+=%3*[%{CheckActiveWindow()}]%r%m%*
  set statusline+=%<
  if has('nvim')
    set statusline+=%4*\ nvim\ %t\ %=%*
  else
    set statusline+=%4*\ vim\ %t\ %=%*
  endif
  set statusline+=%3*%{FugitiveStatusline()}\ %*
  set statusline+=%5*\ %p%%\ %*
  set statusline+=%1*\ %l\*%c\:%L\*%{col('$')}\ %*
else
  " options
  set guicursor=n-v-c:block
  set guicursor+=i:ver100
  set guicursor+=r:ver100
  let &t_SR = "\<Esc>[6 q"
  let &t_SI = "\<Esc>[6 q"
  let &t_EI = "\<Esc>[2 q"
  " sets cursor to a beam in insertmode and block in other modes. Works only for gnome-terminal

  " Plugins
  " call plug#begin()
  " call plug#end()

  " Standard key mappings
  inoremap <silent> :<CR> :<CR><Tab>
  " :\n - :\n\t
  inoremap <silent> {<CR> {<CR>}<Esc>O<Tab>
  " { - {\n\t|\n}
  inoremap <silent> (<CR> (<CR>)<Esc>O<Tab>
  " ( - (\n\t|\n)
  inoremap <silent> [<CR> [<CR>]<Esc>O<Tab>
  " [ - [\n\t|\n]

  " statusline
  set statusline=%{%StatuslineModeReturner()%}
  set statusline+=%2*\ %Y\ %*
  set statusline+=%3*[%{CheckActiveWindow()}]%r%m%*
  set statusline+=%<
  if has('nvim')
    set statusline+=%4*\ nvim\ %t\ %=%*
  else
    set statusline+=%4*\ vim\ %t\ %=%*
  endif
  set statusline+=%5*\ %p%%\ %*
  set statusline+=%1*\ %l\*%c\:%L\*%{col('$')}\ %*
endif


" windows config
if has("win32") || has("win64") || has("win16")
  " key mappings
  nnoremap <silent> <F8> "+p
  inoremap <silent> <F8> <Esc>"+pa
  " paste text to system clipboard
endif
