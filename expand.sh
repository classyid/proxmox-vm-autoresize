#!/bin/bash

# ==========================================
# Script Auto-Expand Storage LVM (Ubuntu)
# ==========================================

# Konfigurasi Device (Berdasarkan setup server Anda)
DISK="/dev/sda"
PART_NUM="3"
PARTITION="${DISK}${PART_NUM}"
LV_PATH="/dev/mapper/ubuntu--vg-ubuntu--lv"

# Cek apakah dijalankan sebagai root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Error: Harap jalankan script ini sebagai root (sudo)."
  exit 1
fi

echo "=== 🚀 Memulai Proses Expand Storage ==="
echo "Target Disk: $DISK"
echo "Target LVM : $LV_PATH"
echo "----------------------------------------"

# Langkah 1: Deteksi perubahan ukuran disk (Growpart)
echo "[1/4] Memperbesar partisi fisik ($PARTITION)..."
# growpart terkadang return non-zero jika tidak ada perubahan, kita tangkap outputnya
OUTPUT_GP=$(growpart "$DISK" "$PART_NUM" 2>&1)
if [[ $? -eq 0 ]]; then
    echo "✅ Partisi berhasil diperbesar."
else
    echo "⚠️ Info: $OUTPUT_GP"
fi

# Langkah 2: Update Physical Volume LVM
echo "[2/4] Mengupdate LVM Physical Volume..."
pvresize "$PARTITION"

# Langkah 3: Extend Logical Volume
echo "[3/4] Mengambil semua free space ke Logical Volume..."
lvextend -l +100%FREE "$LV_PATH"

# Langkah 4: Resize Filesystem (ext4)
echo "[4/4] Resize Filesystem agar terbaca OS..."
resize2fs "$LV_PATH"

echo "----------------------------------------"
echo "=== 🎉 Selesai! Berikut kapasitas baru: ==="
df -h /
