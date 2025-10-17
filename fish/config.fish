if status is-interactive
    set fish_greeting
    set fish_prompt_pwd_dir_length 0
    set fish_cursor_default block
    set fish_cursor_insert line
    set fish_cursor_replace_one block
    set fish_cursor_replace line
    set fish_cursor_visual block
    function findfile
        find . -name $argv[1] -type f,d
    end
    # function nvim
    #   /usr/bin/nvim -u ~/.vimrc $argv
    # end
    # function vim
    #   /usr/bin/nvim $argv
    # end
    function findword
        grep $argv[1] -rnwH . --exclude-dir=node_modules --exclude-dir=.git --exclude=package-lock.json
    end
    function vman
        man $argv | vim -RM -c ':set syntax=man' -
    end
    function c
        set filenamewithoutextension (echo $argv[1] | cut -f 1 -d '.')
        gcc $argv[1] -o $filenamewithoutextension
        chmod +x $filenamewithoutextension
    end
    function rr
        rm -r $argv
    end
    function rf
        rm -rf $argv
    end
    function mkdirp
        mkdir -p $argv
    end
    function rmdirp
        rmdir -p $argv
    end
    function cf
        wl-copy <$argv
    end
    function cr
        cp -r $argv
    end
    function mvno
        mv -n $argv
    end
    function fzfopen
        fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs nvim
    end
    function gitgraph
        git log --all --graph --decorate --pretty="%C(blue)%h %C(yellow)%ad %C(red)%an%C(green)%d%Creset%n%C(magenta)%s%Creset" --abbrev-commit --date=short
    end
    fish_vi_key_bindings
end

# Go path variables
set -gx GOPATH $HOME/go
set -gx PATH $PATH $GOPATH/bin
set -gx PATH $PATH /usr/local/go/bin

# Java variables
set -gx JAVA_HOME /usr/lib/jvm/default
# set -gx JDK_JAVA_OPTIONS

# Maven variables
# set -gx MAVEN_OPTS

# Rust path variables
set -gx PATH $PATH $HOME/.cargo/bin

# Additional user bin path variables
set -gx PATH $PATH $HOME/.local/bin

# Coursier path variables
set -gx PATH $PATH $HOME/.local/share/coursier/bin

# fish_config theme choose Nord
# set -g fish_term24bit 0

zoxide init --cmd cd fish | source
fzf --fish | source
bat --completion fish | source

set -gx FZF_DEFAULT_OPTS "--style full --color 16 --reverse"
set -gx BAT_THEME ansi

if status is-interactive
    and not set -q TMUX
    # Dont use `exec` to start tmux as it causes wsl to quit
    tmux -2u
end
