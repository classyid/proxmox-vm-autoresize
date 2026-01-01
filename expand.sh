#!/bin/bash

# ==========================================
# Script Auto-Expand Storage (Smart Detect)
# ==========================================

# Cek Root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Harap jalankan sebagai root."
  exit 1
fi

echo "=== 🔍 Memeriksa Lingkungan Sistem ==="

# Deteksi Root Filesystem
ROOT_DEV=$(findmnt / -o SOURCE -n)
echo "Root Device terdeteksi: $ROOT_DEV"

# Cek apakah ini Loop device (Indikasi LXC Container)
if [[ "$ROOT_DEV" == *"/dev/loop"* ]]; then
    echo "⚠️  Terdeteksi sistem berjalan pada Loop Device (Kemungkinan LXC Container)."
    echo "ℹ️  Pada LXC, partisi dan LVM diatur oleh Host."
    echo "🔄 Mencoba resize filesystem langsung..."
    
    resize2fs "$ROOT_DEV"
    
    if [[ $? -eq 0 ]]; then
        echo "✅ Resize Filesystem LXC Berhasil!"
    else
        echo "❌ Gagal. Pastikan Anda sudah menambah ukuran disk via Proxmox GUI."
    fi
    
    echo "=== Selesai ==="
    df -h /
    exit 0
fi

# --- BAGIAN BAWAH INI HANYA UNTUK VM BIASA (NON-LXC) ---

echo "=== 🛠️ Memeriksa Kelengkapan Tools (VM) ==="

# Cek dan Install growpart
if ! command -v growpart &> /dev/null; then
    echo "📦 Menginstall cloud-guest-utils..."
    apt-get update && apt-get install -y cloud-guest-utils
fi

# Cek dan Install LVM
if ! command -v lvextend &> /dev/null; then
    echo "📦 Menginstall lvm2..."
    apt-get install -y lvm2
fi

# Konfigurasi LVM Default Ubuntu
DISK="/dev/sda"
PART_NUM="3"
PARTITION="${DISK}${PART_NUM}"
LV_PATH=$(lvdisplay | grep "LV Path" | awk '{print $3}' | head -n 1)

if [ -z "$LV_PATH" ]; then
    echo "❌ Tidak dapat menemukan Logical Volume LVM otomatis."
    echo "   Silakan cek manual dengan 'lsblk'."
    exit 1
fi

echo "Target Disk: $DISK"
echo "Target LVM : $LV_PATH"

# 1. Growpart
echo "[1/4] Growpart..."
growpart "$DISK" "$PART_NUM"

# 2. PV Resize
echo "[2/4] PV Resize..."
pvresize "$PARTITION"

# 3. LV Extend
echo "[3/4] LV Extend..."
lvextend -l +100%FREE "$LV_PATH"

# 4. Resize FS
echo "[4/4] Resize Filesystem..."
resize2fs "$LV_PATH"

echo "=== 🎉 Selesai! ==="
df -h /
