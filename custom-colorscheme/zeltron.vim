" Color Scheme and Config

syntax on
" turns on color highlighting of the code
if exists("syntax_on")
	syntax reset
	" resets the colors for some of the highlight groups if syntax is on
endif

set background=dark
let g:colors_name="zeltron"

set guicursor=n-v-c-i:block
" sets cursor to a block in vim.

highlight clear
" clears all the highlighting set before.
" [See this link read all the matter under naming conventions category to know about highlight groups and which part of the code do they highlight](http://vimdoc.sourceforge.net/htmldoc/syntax.html)
" [Also for changing colors, replace the numbers for cterfg and ctermbg if present with your favourite ones by referring to this link](https://jonasjacek.github.io/colors/)
" Basic text
highlight Comment ctermfg=214 cterm=none
highlight Normal ctermfg=46 ctermbg=0 cterm=none
" Basic Types
highlight Constant ctermfg=226 cterm=none
highlight Number ctermfg=226 cterm=none
highlight Float ctermfg=226 cterm=none
highlight Boolean ctermfg=226 cterm=none
highlight String ctermfg=226 cterm=none
highlight Character ctermfg=226 cterm=none
" Variables and Functions
highlight Identifier ctermfg=21 cterm=none
highlight Function ctermfg=21 cterm=none
" Code
highlight Statement ctermfg=21 cterm=none
highlight Conditional ctermfg=21 cterm=none
highlight Repeat ctermfg=21 cterm=none
highlight Label ctermfg=21 cterm=none
highlight Operator ctermfg=21 cterm=none
highlight Keyword ctermfg=21 cterm=none
highlight Exception ctermfg=21 cterm=none
" Pre processed code
highlight PreProc ctermfg=51 cterm=none
highlight Include ctermfg=51 cterm=none
highlight Define ctermfg=51 cterm=none
highlight Macro ctermfg=51 cterm=none
highlight Precondit ctermfg=51 cterm=none
" Classes and Structures
highlight Type ctermfg=21 cterm=none
highlight StorageClass ctermfg=21 cterm=none
highlight Structure ctermfg=21 cterm=none
highlight Typedef ctermfg=21 cterm=none
" Special Text
highlight Special ctermfg=93 cterm=none
highlight SpecialChar ctermfg=93 cterm=none
highlight Tag ctermfg=93 cterm=none
highlight Delimiter ctermfg=93 cterm=none
highlight SpecialComment ctermfg=93 cterm=none
highlight Debug ctermfg=93 cterm=none
" Others
highlight Underlined ctermfg=13 cterm=none
highlight Ignore ctermfg=21 cterm=none
highlight Error ctermfg=231 ctermbg=75 cterm=none
highlight Todo ctermfg=51 ctermbg=196 cterm=none
" Vi-related
highlight Cursor ctermfg=196 ctermbg=46 cterm=none
" This highlight group is to set color for your cursor altough the cursor color has to be set in your preferences tab in the terminal to change.
highlight SpecialKey ctermfg=240 cterm=none
" sets color for special keys
highlight ErrorMsg ctermfg=231 ctermbg=75 cterm=none
" This highlight group is to set color for error messages.
highlight Directory ctermfg=21 cterm=bold
" sets color for directories
highlight Search ctermfg=196 ctermbg=51 cterm=none
" sets color for search group
highlight IncSearch ctermfg=196 ctermbg=51 cterm=none
" sets color of incsearch
highlight WarningMsg ctermfg=231 ctermbg=75 cterm=none
" sets color of warning messages
highlight Visual ctermbg=59 cterm=none
highlight VisualNOS ctermbg=59 cterm=none
" sets color for visual mode
highlight WildMenu ctermfg=231 ctermbg=46
" sets color for wildmenu
highlight CursorLine ctermbg=238 cterm=bold
highlight CursorLineNR ctermfg=0 ctermbg=11 cterm=bold
" This hightlight group is to set the color for highlighting horizontal line in which you cursor lies.
highlight StatusLine ctermfg=0 ctermbg=11 cterm=bold
" sets color for statusline
highlight StatusLineNC ctermfg=0 ctermbg=15 cterm=bold
" sets color for statusline of other tabs
highlight CursorColumn ctermbg=238 cterm=bold
" This highlight group is to set the color for highlighting vertical line in which your cursor lies.
highlight LineNR ctermfg=0 ctermbg=15 cterm=bold
" This highlight group is to set the color of linenumbering.
highlight NonText ctermfg=240 cterm=none
" This highlight group is for setting colors to nontext or invisible characters which replace your tabs, spaces, trailing spaces,etc.

highlight MatchParen ctermfg=14 ctermbg=21 cterm=bold
" This highlights group is for setting color for matching paranthesis in vim.

" Diff settings
highlight DiffAdd ctermfg=233 ctermbg=194 cterm=none
highlight DiffChange ctermfg=194 ctermbg=255 cterm=none
highlight DiffText ctermfg=233 ctermbg=189 cterm=none
highlight DiffDelete ctermfg=252 ctermbg=224 cterm=none

" Pmenu
highlight Pmenu ctermfg=16 ctermbg=46 cterm=bold
" sets color for panelmenu
highlight PmenuSel ctermfg=16 ctermbg=21 cterm=bold
" sets color for panel menu selection
highlight PmenuSbar ctermfg=16 ctermbg=0 cterm=bold
" sets color for PmenuSBar
highlight PmenuThumb ctermfg=16 ctermbg=0 cterm=bold
" sets color for PmenuThumb
" Invisible Characters
set listchars=eol:¬,tab:\|\·,trail:~,extends:>,precedes:<
" These are the characters which will replace your invisible characters like tabs spaces. Also if you want to represent all the spaces in your code with some character, you can replace this line with this code 'set listchars=eol:¬,tab:\|\·,trail:~,extends:>,precedes:<,space:~' and replace the space with whatever character you want.

highlight Directory ctermfg=21 ctermbg=9 cterm=none
highlight VertSplit ctermfg=none ctermbg=none cterm=none
highlight Folded ctermfg=8 ctermbg=15 cterm=bold
highlight FoldColumn ctermfg=50 ctermbg=7 cterm=none
highlight SignColumn ctermfg=8 ctermbg=7 cterm=none
highlight ModeMsg ctermfg=231 ctermbg=75 cterm=none
highlight MoreMsg ctermfg=231 ctermbg=75 cterm=none
highlight Question ctermfg=231 cterm=none
highlight SpecialKey ctermfg=8 cterm=none
highlight TabLine ctermfg=238 ctermbg=188 cterm=none
highlight TabLineFill ctermfg=238 ctermbg=188 cterm=none
highlight TabLineSel ctermfg=238 ctermbg=11 cterm=bold
highlight Title ctermfg=11 ctermbg=21 cterm=none
highlight Conceal ctermfg=21 cterm=none

" HTML
" highlight htmlArg ctermfg=21 cterm=none
" highlight htmlEndTag ctermfg=21 cterm=none
" highlight htmlTag ctermfg=21 cterm=none
" highlight htmlTagName ctermfg=21 cterm=none
" highlight htmlTitle ctermfg=21 cterm=none

" Javascript
" highlight javaScriptBraces ctermfg=196 cterm=none
" highlight javaScriptIdentifier ctermfg=21 cterm=none
" highlight javaScriptFunction ctermfg=21 cterm=none
" highlight javaScriptNumber ctermfg=21 cterm=none
" highlight javaScriptReserved ctermfg=21 cterm=none
" highlight javaScriptRequire ctermfg=21 cterm=none
" highlight javaScriptNone ctermfg=21 cterm=none

" Ruby
" highlight rubyBlockParameterList ctermfg=93 cterm=none
" highlight rubyInterpolationDelimiter ctermfg=93 cterm=none
" highlight rubyStringDelimiter ctermfg=93 cterm=none
" highlight rubyRegexpSpecial ctermfg=93 cterm=none

" Special commands and Characters for copy/paste :- "¬·"
" source ~/.vim/colors/zeltron.vim
au WinEnter,TabEnter,BufEnter * match ExtraText /[(){}<>.~,?/\|:;!@#$%^&*\-+\[\]="'`]/|2match Number /[0123456789]/
highlight ExtraText ctermfg=196 cterm=none
" This highlight group is created by me to color all the special characters.
