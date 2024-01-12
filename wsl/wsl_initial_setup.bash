#!/bin/bash

set -e

passwd
echo "%wheel ALL=(ALL) ALL" > /etc/sudoers.d/wheel
useradd -m -G wheel -s /bin/bash zeltron
passwd zeltron

echo -e "\e[32mRun the following command to set zeltron as default user 'Arch.exe config --default-user zeltron'\e[0m"
echo -e "\e[32mReboot the computer if user not set as default or run the following command 'net stop lxssmanager && net start lxssmanager'\e[0m"
exit
