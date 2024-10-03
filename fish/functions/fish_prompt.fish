function fish_prompt
    set_color -o
    echo (set_color cyan)'['(set_color blue)(whoami)(set_color red)'@'(set_color blue)(prompt_hostname)(set_color cyan)']'
    echo (set_color cyan)'['(set_color blue)(prompt_pwd)(set_color cyan)']'
    if string length --quiet (fish_git_prompt)
      echo (set_color cyan)'['(set_color blue)(fish_git_prompt | xargs)(set_color cyan)']'
    end
    if fish_is_root_user
        echo -n (set_color cyan)'['(set_color red)'#'(set_color cyan)']'(set_color yellow)': '
    else
        echo -n (set_color cyan)'['(set_color red)'$'(set_color cyan)']'(set_color yellow)': '
    end
    set_color normal
end
