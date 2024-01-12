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
	# 	/usr/bin/nvim -u ~/.vimrc $argv
	# end
	# function vim
	# 	/usr/bin/nvim $argv
	# end
	function findword
		grep $argv[1] -rnwH . --exclude-dir=node_modules --exclude-dir=.git --exclude=package-lock.json
	end
	function vman
		man $argv | vim -RM -c ':set syntax=man' - ;
	end
	function c
		set filenamewithoutextension (echo $argv[1] | cut -f 1 -d '.');
		gcc $argv[1] -o $filenamewithoutextension;
		chmod +x $filenamewithoutextension;
	end
	function rr
		rm -r $argv;
	end
	function rf
		rm -rf $argv;
	end
	function mkdirp
		mkdir -p $argv;
	end
	function rmdirp
		rmdir -p $argv;
	end
	function cf
		wl-copy < $argv;
	end
	function cr
		cp -r $argv;
	end
	function mvno
		mv -n $argv;
	end
	function fzfopen
		fd --type f --hidden --exclude .git | fzf-tmux -p --reverse | xargs nvim
	end
	fish_vi_key_bindings
end

set -x GOPATH $HOME/go
set -x PATH $PATH $GOPATH/bin
set -x PATH $PATH $HOME/.local/bin
set -x PATH $PATH $HOME/.cargo/bin

if status is-interactive
and not set -q TMUX
	exec tmux -2u
end
