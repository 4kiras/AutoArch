#!/bin/bash

echo "[+] Iniciando instalación de GNOME minimal + NVIDIA + AUR (yay)"
sleep 1

# -------------------- SISTEMA BÁSICO --------------------
sudo pacman -Syu --noconfirm
sudo pacman -S --noconfirm \
  gnome-shell \
  gnome-session \
  gdm \
  mutter \
  gnome-control-center \
  gnome-settings-daemon \
  gnome-terminal \
  nautilus \
  networkmanager \
  gvfs \
  xdg-user-dirs \
  gnome-tweaks \
  gnome-keyring \
  xorg-xwayland \
  git \
  wget \
  unzip \
  gnome-shell-extensions \
  gnome-backgrounds \
  file-roller \
  papirus-icon-theme \
  arc-gtk-theme \
  gnome-themes-extra \
  gnome-shell-extension-manager \
  base-devel

# -------------------- AUR: INSTALACIÓN DE YAY --------------------
echo "[+] Instalando yay para AUR..."
cd /opt
sudo git clone https://aur.archlinux.org/yay.git
sudo chown -R "$USER":"$USER" yay
cd yay
makepkg -si --noconfirm

# -------------------- DETECCIÓN NVIDIA --------------------
echo "[+] Detectando tarjeta gráfica NVIDIA..."
if lspci | grep -E "VGA|3D" | grep -i nvidia; then
    echo "[✔] NVIDIA detectada. Instalando drivers propietarios..."
    
    # Selección inteligente
    if [ "$(uname -r | grep -c 'lts')" -gt 0 ]; then
        sudo pacman -S --noconfirm nvidia-lts
    else
        sudo pacman -S --noconfirm nvidia nvidia-utils nvidia-settings
    fi

    # Configuración automática
    echo "[+] Configurando módulos de NVIDIA..."
    sudo bash -c "echo 'options nvidia_drm modeset=1' > /etc/modprobe.d/nvidia.conf"
    sudo mkinitcpio -P
    sudo sed -i 's/^#WaylandEnable=false/WaylandEnable=false/' /etc/gdm/custom.conf

else
    echo "[!] No se detectó una GPU NVIDIA. Saltando instalación de drivers."
fi

# -------------------- CONFIGURACIÓN VISUAL --------------------
xdg-user-dirs-update

mkdir -p ~/Imágenes
wget -O ~/Imágenes/kali.jpg https://gitlab.com/kalilinux/packages/kali-wallpapers/-/raw/kali/master/kali/kali-2019.jpg

gsettings set org.gnome.desktop.background picture-uri "file://$HOME/Imágenes/kali.jpg"
gsettings set org.gnome.desktop.interface gtk-theme "Arc-Dark"
gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
gsettings set org.gnome.desktop.interface enable-animations true
gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark'
gsettings set org.gnome.nautilus.preferences default-folder-viewer 'list-view'

gnome-extensions enable user-theme@gnome-shell-extensions.gcampax.github.com 2>/dev/null
gnome-extensions enable apps-menu@gnome-shell-extensions.gcampax.github.com 2>/dev/null
gnome-extensions enable places-menu@gnome-shell-extensions.gcampax.github.com 2>/dev/null

# -------------------- ACTIVAR SERVICIOS --------------------
sudo systemctl enable gdm
sudo systemctl enable NetworkManager

echo "[✔] Todo listo. Reinicia tu equipo para comenzar a usar GNOME + Wayland + NVIDIA + AUR."
