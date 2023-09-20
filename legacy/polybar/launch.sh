# colors
export polybar_text_name_background="#1c1c1c"
export polybar_background="#CC2E3436"
export polybar_foreground="#b2b2b2"
export polybar_module_name_background="#374549"
export polybar_module_name_foreground="#ffaf00"
export polybar_tray_background="#374549"
export polybar_tray_foreground="#ffaf00"
export polybar_x_active_foreground="#ffaf00"
export polybar_x_active_background="#374549"
export polybar_x_occupied_background="#1c1c1c"
export polybar_x_occupied_foreground="#ffaf00"
export polybar_x_urgent_background="#ff0000"
export polybar_x_urgent_foreground="#000000"
export polybar_x_background="#1c1c1c"

# network module
export polybar_network_module_connected="%{B$polybar_text_name_background} %downspeed% ↓ %{B-}%{B$polybar_module_name_background}%{F$polybar_module_name_foreground}  %{T2} %{T-}%{B- F-}%{B$polybar_text_name_background} ↑ %upspeed% %{B-}"
export polybar_network_module_disconnected="%{B$polybar_module_name_background}%{F$polybar_module_name_foreground} Disconnected %{B- F-}"

# battery module
export polybar_battery_module_full="%{B$polybar_module_name_background}%{F$polybar_module_name_foreground}   %{B- F-}"
export polybar_battery_module_charging="%{B$polybar_module_name_background}%{F$polybar_module_name_foreground}   %{B- F-}%{B$polybar_text_name_background} %percentage%% ↑ %{B-}"
export polybar_battery_module_discharging="%{B$polybar_module_name_background}%{F$polybar_module_name_foreground}   %{B- F-}%{B$polybar_text_name_background} %percentage%% ↓ %{B-}"
export polybar_battery_module_low="%{B$polybar_module_name_background}%{F$polybar_module_name_foreground}   %{B- F-}%{B$polybar_text_name_background} %percentage%% %{B-}"

# filesystem module
export polybar_filesystem_module_mounted="%{B$polybar_module_name_background}%{F$polybar_module_name_foreground}  %{T2} %{T-}%{B- F-}%{B$polybar_text_name_background} %percentage_used%% %{B-}"

killall -q polybar; polybar -q -r -c $HOME/.config/polybar/config.ini xeltron &
