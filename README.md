# Proxmox VM Auto Resize Script (LVM)

Script bash sederhana untuk mengotomatiskan proses penambahan kapasitas storage (resize) pada Virtual Machine Ubuntu/Debian yang menggunakan LVM di lingkungan Proxmox VE.

Script ini menangani proses:
1. `growpart` (Memperbesar partisi fisik)
2. `pvresize` (Update LVM Physical Volume)
3. `lvextend` (Extend Logical Volume ke 100% free space)
4. `resize2fs` (Resize filesystem agar terbaca OS)

## 🚀 Cara Penggunaan

### Langkah 1: Resize di Proxmox
Pastikan Anda sudah memperbesar ukuran disk VM melalui panel Proxmox (**Hardware** > **Hard Disk** > **Disk Action** > **Resize**).

### Langkah 2: Jalankan Script di VM
Login ke VM Anda via SSH, lalu jalankan perintah berikut:

**Opsi A: One-Liner (Langsung Jalan)**
```bash
curl -sL [https://raw.githubusercontent.com/classyid/proxmox-vm-autoresize/main/expand.sh](https://raw.githubusercontent.com/classyid/proxmox-vm-autoresize/main/expand.sh) | sudo bash
