The same config file works for both vim and neovim. Rename `.vimrc` to `init.vim` and move to `~/.config/nvim/` for neovim to work in linux.<br>
For windows copy the contents of config, enter vim, go to normal mode, type the command `:edit $HOME/_vimrc` and paste the contents of using `"+p` and save them.<br>
To install vim-plug in linux, run the following commands:-
```bash
curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
```
```bash
sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
```
To install the plugins, run the following command:-
```
:PlugInstall
:PlugUpdate
```
To install coc plugins and make ale work with coc.nvim:-
```
:CocInstall coc-angular coc-texlab coc-markmap
:CocInstall @yaegassy/coc-nginx coc-phpactor coc-ltex
:CocInstall coc-docker coc-toml coc-xml
:CocInstall coc-yaml coc-marketplace coc-prettier
:CocInstall coc-sh coc-clangd coc-deno
:CocInstall coc-go coc-html coc-java
:CocInstall coc-tsserver coc-json coc-pyright
:CocInstall coc-solargraph coc-rls coc-css
:CocInstall coc-eslint coc-snippets coc-sql
:CocUpdate
```
To generate coc.nvim config file and write in it:-
```
:CocConfig
```
coc.nvim config file:-
```json
{
  "diagnostic.displayByAle": true
}
```
