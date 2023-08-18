pacman-key --init
pacman-key --populate archlinux

setfont ter-132b

cfdisk
# create /dev/sda3 as /, /dev/sda2 as swap and /dev/sda1 as efi if not present.

mkfs.ext4 /dev/sda3
mkfs.fat -F 32 /dev/sda1
mkswap /dev/sda2

swapon /dev/sda2

mount --mkdir /dev/sda3 /mnt
mount --mkdir /dev/sda1 /mnt/boot/efi

pacman -S reflector --needed --noconfirm

mv /etc/pacman.d/mirrorlist /etc/pacman.d/mirrorlist.bak

reflector --latest 5 --country India --protocol https --sort rate --save /etc/pacman.d/mirrorlist

echo 'ParallelDownloads = 5' >> /etc/pacman.conf
echo '[multilib]' >> /etc/pacman.conf
echo 'Include = /etc/pacman.d/mirrorlist' >> /etc/pacman.conf

pacstrap -K /mnt base base-devel linux linux-lts linux-headers linux-lts-headers linux-firmware intel-ucode sudo vim git neofetch networkmanager dhcpcd pipewire blueman wayland hyprland

genfstab -U /mnt /mnt/etc/fstab

arch-chroot /mnt

ln -sf /usr/share/zoneinfo/Asia/Kolkata /etc/localtime

hwclock --systohc

echo 'en_IN UTF-8' >> /etc/locale.gen

echo 'LANG=en_IN.UTF-8' >> /etc/locale.conf

locale-gen

echo 'xeltron' >> /etc/hostname

passwd

useradd -m zeltron

passwd zeltron

echo '%wheel ALL=(ALL:ALL) ALL' | (EDITOR="tee -a" visudo)

usermod -aG wheel zeltron

pacman -S efibootmgr grub --needed --noconfirm

echo 'GRUB_DISABLE_OS_PROBER=false' >> /etc/default/grub

pacman -S os-prober --needed --noconfirm

grub-install --target=x86_64-efi --bootloader-id=GRUB --recheck

grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable dhcpcd

systemctl enable NetworkManager
