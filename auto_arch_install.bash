#!/bin/bash

set -e

DISK1="/dev/sda" # SSD de 128GB → /
DISK2="/dev/sdb" # HDD de 480GB → /boot y /home

echo "⚠️ Esto ELIMINARÁ TODO en $DISK1 y $DISK2. ¿Continuar? (yes/no)"
read CONFIRM
[ "$CONFIRM" != "yes" ] && exit 1

echo "💽 Particionando discos..."
wipefs -a $DISK1
parted -s $DISK1 mklabel gpt mkpart primary ext4 1MiB 100%
wipefs -a $DISK2
parted -s $DISK2 mklabel gpt
parted -s $DISK2 mkpart primary fat32 1MiB 512MiB  # /boot ahora es FAT32
parted -s $DISK2 mkpart primary ext4 512MiB 100%       # /home

echo "🧼 Formateando particiones..."
mkfs.ext4 ${DISK1}1
mkfs.fat -F32 ${DISK2}1      # Formateamos /boot como FAT32
mkfs.ext4 ${DISK2}2

echo "📁 Montando sistema..."
mount ${DISK1}1 /mnt
mkdir /mnt/boot /mnt/home
mount ${DISK2}1 /mnt/boot
mount ${DISK2}2 /mnt/home

echo "📦 Instalando sistema base..."
pacstrap /mnt base linux linux-firmware nano networkmanager grub sudo bluez bluez-utils gnome gnome-tweaks gdm git lsb-release firefox neofetch telegram-desktop vlc curl \
  gnome-themes-extra arc-gtk-theme papirus-icon-theme lxappearance nmap wireshark-qt metasploit sqlmap hashcat netcat whois traceroute exiftool

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

grub-install --target=i386-pc $DISK2
grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable bluetooth
systemctl start bluetooth
systemctl enable gdm

# 🔍 NVIDIA autodetect + instalación de drivers propietarios
echo "🔍 Buscando GPU NVIDIA..."
if lspci | grep -E "NVIDIA|GeForce"; then
    echo "💡 NVIDIA detectada. Instalando drivers propietarios..."
    pacman -S --noconfirm nvidia nvidia-utils nvidia-settings
    echo "options nvidia_drm modeset=1" >> /etc/modprobe.d/nvidia.conf
    mkinitcpio -P
else
    echo "❌ No se detectó NVIDIA. Saltando instalación de drivers."
fi

# 🛠️ Instalando AUR (yay)
echo "📥 Instalando yay..."
pacman -S --needed --noconfirm base-devel
sudo -u akira bash -c "cd /home/akira && git clone https://aur.archlinux.org/yay.git && cd yay && makepkg -si --noconfirm"

# 🎨 Configuración de apariencia estilo Kali Linux
echo "🔧 Aplicando apariencia estilo Kali..."
gsettings set org.gnome.desktop.interface gtk-theme "Arc-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
gsettings set org.gnome.shell.extensions.user-theme name "Arc-Dark"

echo "✅ Instalación completada. Reinicia para aplicar los cambios."
EOF

echo "🚀 Todo listo. Reinicia la máquina cuando estés preparado."
