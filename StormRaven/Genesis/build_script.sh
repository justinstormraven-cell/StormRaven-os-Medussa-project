#!/bin/bash
set -e

# CONFIG
KERNEL_VER="6.6.14"
BB_VER="1.36.1"
WORK_DIR="/root/forge"
OUT_DIR="/root/output"
ROOTFS_DIR="/root/rootfs"

echo "[FORGE] Installing Dependencies..."
apt-get update
apt-get install -y build-essential bison flex libncurses-dev libssl-dev libelf-dev dwarves bc wget cpio qemu-system-x86 rsync git kmod pkg-config grub-pc-bin grub-efi-amd64-bin xorriso

mkdir -p $WORK_DIR $OUT_DIR $ROOTFS_DIR

# 1. KERNEL COMPILATION
echo "[FORGE] Fetching Kernel $KERNEL_VER..."
cd $WORK_DIR
wget -q https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-$KERNEL_VER.tar.xz
tar -xf linux-$KERNEL_VER.tar.xz
cd linux-$KERNEL_VER
echo "[FORGE] Configuring Kernel for Virtualization..."
make x86_64_defconfig
# Enable VirtIO for QEMU/VirtualBox
./scripts/config --enable CONFIG_KVM_GUEST
./scripts/config --enable CONFIG_VIRTIO_PCI
./scripts/config --enable CONFIG_VIRTIO_NET
./scripts/config --enable CONFIG_VIRTIO_BLK
./scripts/config --enable CONFIG_E1000
echo "[FORGE] Compiling bzImage (This takes time)..."
make -j$(nproc) bzImage
cp arch/x86/boot/bzImage $OUT_DIR/

# 2. BUSYBOX COMPILATION (STATIC)
echo "[FORGE] Building BusyBox $BB_VER..."
cd $WORK_DIR
wget -q https://busybox.net/downloads/busybox-$BB_VER.tar.bz2
tar -xf busybox-$BB_VER.tar.bz2
cd busybox-$BB_VER
make defconfig
sed -i 's/^# CONFIG_STATIC is not set/CONFIG_STATIC=y/' .config
make -j$(nproc) install CONFIG_PREFIX=$ROOTFS_DIR

# 3. LEVIATHAN INJECTION
echo "[FORGE] Injecting Soul..."
cd $ROOTFS_DIR
mkdir -p dev proc sys tmp mnt/alfheim mnt/stealth mnt/vault var/log opt/storm-raven boot/grub
# Move the init script we uploaded
mv /root/init_script $ROOTFS_DIR/init
chmod +x $ROOTFS_DIR/init

# Create the RAM disk
find . -print0 | cpio --null -o --format=newc | gzip -9 > $OUT_DIR/initramfs.cpio.gz

# 4. ISO MASTERING (GRUB2)
echo "[FORGE] Mastering Artifact..."
mkdir -p $WORK_DIR/iso/boot/grub
cp $OUT_DIR/bzImage $WORK_DIR/iso/boot/
cp $OUT_DIR/initramfs.cpio.gz $WORK_DIR/iso/boot/

cat > $WORK_DIR/iso/boot/grub/grub.cfg <<EOF
set timeout=5
set default=0
menuentry "STORM RAVEN OS (Leviathan Protocol)" {
    echo "Loading Odin (Kernel 6.6)..."
    linux /boot/bzImage console=tty0 quiet
    echo "Loading Yggdrasil (RootFS)..."
    initrd /boot/initramfs.cpio.gz
}
EOF

grub-mkrescue -o $OUT_DIR/StormRaven.iso $WORK_DIR/iso

# 5. HANDOFF
# Note: We use the injected user from SCP
cp $OUT_DIR/StormRaven.iso /home/architect/
chown architect:architect /home/architect/StormRaven.iso
echo "[FORGE] Artifact Ready."