#!/bin/bash

set -e

DISK="/dev/sda"  # Disco único en la VM

echo "⚠️ Esto ELIMINARÁ TODO en $DISK. ¿Continuar? (yes/no)"
read CONFIRM
[ "$CONFIRM" != "yes" ] && exit 1

echo "💽 Particionando disco..."
wipefs -a $DISK
parted -s $DISK mklabel gpt mkpart primary ext4 1MiB 100%

echo "🧼 Formateando partición..."
mkfs.ext4 ${DISK}1

echo "📁 Montando sistema..."
mount ${DISK}1 /mnt

echo "📦 Instalando sistema base..."
pacstrap /mnt base linux linux-firmware nano networkmanager grub sudo gnome gnome-tweaks gdm git lsb-release firefox neofetch telegram-desktop vlc curl \
  gnome-themes-extra arc-gtk-theme papirus-icon-theme lxappearance qemu-guest-agent \
  nmap wireshark-qt metasploit sqlmap hashcat netcat whois traceroute exiftool

genfstab -U /mnt >> /mnt/etc/fstab

arch-chroot /mnt /bin/bash <<EOF
ln -sf /usr/share/zoneinfo/America/Guayaquil /etc/localtime
hwclock --systohc

echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

echo "4kiras" > /etc/hostname
cat >> /etc/hosts << HOSTS
127.0.0.1 localhost
::1       localhost
127.0.1.1 4kiras.localdomain 4kiras
HOSTS

useradd -m -G wheel,wireshark -s /bin/bash akira
echo "Establece la contraseña para akira:"
passwd akira
echo "Establece la contraseña para root:"
passwd

sed -i 's/# %wheel ALL=(ALL:ALL) ALL/%wheel ALL=(ALL:ALL) ALL/' /etc/sudoers

grub-install --target=i386-pc $DISK
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable gdm
systemctl enable qemu-guest-agent  # Habilita integración con la VM

# 🛠️ Instalando AUR (yay)
echo "📥 Instalando yay..."
pacman -S --needed --noconfirm base-devel
sudo -u akira bash -c "cd /home/akira && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm"

# 🎨 Configuración de apariencia tipo Kali Linux
echo "🔧 Aplicando apariencia estilo Kali..."
gsettings set org.gnome.desktop.interface gtk-theme "Arc-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
gsettings set org.gnome.shell.extensions.user-theme name "Arc-Dark"

echo "✅ Instalación completada. Reinicia la máquina virtual para aplicar los cambios."
EOF

echo "🚀 Instalación en VM lista. Reinicia cuando estés preparado."
