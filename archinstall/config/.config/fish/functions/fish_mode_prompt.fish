function fish_mode_prompt
    set_color -o
    switch $fish_bind_mode
        case default
            echo (set_color brcyan)'['(set_color yellow)'N'(set_color brcyan)']'(set_color yellow)':'
        case insert
            echo (set_color brcyan)'['(set_color green)'I'(set_color brcyan)']'(set_color yellow)':'
        case replace_one
            echo (set_color brcyan)'['(set_color red)'r'(set_color brcyan)']'(set_color yellow)':'
        case visual
            echo (set_color brcyan)'['(set_color brmagenta)'V'(set_color brcyan)']'(set_color yellow)':'
        case replace
            echo (set_color brcyan)'['(set_color red)'R'(set_color brcyan)']'(set_color yellow)':'
        case '*'
            echo (set_color brcyan)'['(set_color blue)'r'(set_color brcyan)']'(set_color yellow)':'
    end
    set_color normal
end
