# 🚀 Instalador Automático de Arch Linux  

Este repositorio contiene **dos scripts** para instalar Arch Linux de manera automatizada:  

1️⃣ **`auto_arch.sh`** → Instalación en hardware real con **dos discos**.  
2️⃣ **`auto_arch_vm.sh`** → Instalación en **máquinas virtuales** con un solo disco.  

## 📦 Contenido  

- `auto_arch.sh` → Script para instalar Arch en un **PC con dos discos** (uno para `/` y otro para `/boot` y `/home`).  
- `auto_arch_vm.sh` → Script para instalar Arch en una **máquina virtual** (un solo disco).  
- `README.md` → Instrucciones detalladas.  

---

## 🔧 **Requisitos Previos**  

📌 **Para ambos scripts:**  
- Arrancar desde una **ISO de Arch Linux Live**.  
- Tener conexión a Internet.  

📌 **Para `auto_arch.sh` (PC real):**  
- **Dos discos:**  
  - **SSD** (Ejemplo: `/dev/sda`) → Para `/`.  
  - **HDD** (Ejemplo: `/dev/sdb`) → Para `/boot` (FAT32) y `/home`.  

📌 **Para `auto_arch_vm.sh` (VM):**  
- **Máquina Virtual** en QEMU, VirtualBox o VMware.  
- **Un solo disco virtual.**  

---

## 🏗 **Instalación en Hardware Real (`auto_arch.sh`)**  

1️⃣ **Descargar el script** en el entorno live de Arch:  

```bash
pacman -Sy git
git clone https://github.com/tu_usuario/arch-installer.git
cd arch-installer
chmod +x auto_arch.sh
