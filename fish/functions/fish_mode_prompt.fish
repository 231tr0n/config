function fish_mode_prompt
    set_color -o
    switch $fish_bind_mode
        case default
            echo (set_color cyan)'['(set_color yellow)'N'(set_color cyan)']'(set_color yellow)':'
        case insert
            echo (set_color cyan)'['(set_color green)'I'(set_color cyan)']'(set_color yellow)':'
        case replace_one
            echo (set_color cyan)'['(set_color red)'r'(set_color cyan)']'(set_color yellow)':'
        case visual
            echo (set_color cyan)'['(set_color magenta)'V'(set_color cyan)']'(set_color yellow)':'
        case replace
            echo (set_color cyan)'['(set_color red)'R'(set_color cyan)']'(set_color yellow)':'
        case '*'
            echo (set_color cyan)'['(set_color blue)'r'(set_color cyan)']'(set_color yellow)':'
    end
    set_color normal
end
