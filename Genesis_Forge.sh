#!/usr/bin/env bash

# ==============================================================================
# STORMRAVEN OS: GENESIS FORGE (ISO RECONSTRUCTION)
# ==============================================================================
# Role: Bundles the StormRaven Kernel and Medussa Project into a bootable ISO.
# Target: Ubuntu 24.04 AMD64
# ==============================================================================

set -euo pipefail

AMETHYST='\033[38;5;135m'
CYAN='\033[0;36m'
GOLD='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${AMETHYST}[†] INITIATING GENESIS FORGE: DISK IMAGE SYNTHESIS...${RESET}"

# 1. Dependency Check
echo -e "${CYAN}[*] Verifying image manipulation toolchain...${RESET}"
sudo apt-get update -qq
sudo apt-get install -y xorriso squashfs-tools mtools libguestfs-tools >/dev/null 2>&1

# 2. Workspace Setup
SOURCE_ISO=$(ls ubuntu-*.iso | head -n 1 || echo "")
if [ -z "$SOURCE_ISO" ]; then
    echo -e "${RED}[!] ERROR: Base Ubuntu ISO not found in current directory.${RESET}"
    exit 1
fi

WORK_DIR="/tmp/stormraven_genesis"
mkdir -p "$WORK_DIR/iso" "$WORK_DIR/squashfs"
sudo mount -o loop "$SOURCE_ISO" "$WORK_DIR/iso"

# 3. Extract and Modify Filesystem
echo -e "${CYAN}[*] Extracting base filesystem (SquashFS)...${RESET}"
cp -r "$WORK_DIR/iso/"* "$WORK_DIR/new_iso/" 2>/dev/null || true
chmod -R +w "$WORK_DIR/new_iso"

# Copy StormRaven Kernel Artifacts into the ISO's 'pool' or a custom folder
echo -e "${GOLD}[*] Injecting StormRaven-Leviathan Kernel Artifacts...${RESET}"
mkdir -p "$WORK_DIR/new_iso/stormraven_core"
cp ../linux-image-*.deb "$WORK_DIR/new_iso/stormraven_core/"
cp ../linux-headers-*.deb "$WORK_DIR/new_iso/stormraven_core/"

# 4. Integrate Medussa Project Logic
echo -e "${CYAN}[*] Embedding Medussa Project environment...${RESET}"
# We bundle the repo into the ISO so it's available even without net access
git clone https://github.com/justinstormraven-cell/StormRaven-os-Medussa-project.git "$WORK_DIR/new_iso/stormraven_core/medussa-repo"

# 5. Patch Boot Configuration
echo -e "${GOLD}[*] Patching GRUB for automated autoinstall detection...${RESET}"
sed -i 's/---/ autoinstall ds=nocloud;s=\/cdrom\/nocloud\/ ---/g' "$WORK_DIR/new_iso/boot/grub/grub.cfg"

# 6. Repackaging the Golden Master
echo -e "${AMETHYST}[†] Forging the final ISO: StormRaven-OS-Leviathan.iso...${RESET}"
cd "$WORK_DIR/new_iso"
xorriso -as mkisofs \
  -r -V "STORMRAVEN_OS" \
  -o "../../StormRaven-OS-Leviathan.iso" \
  -J -l -b boot/grub/i386-pc/eltorito.img \
  -c boot.catalog \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e boot/grub/efi.img \
  -no-emul-boot \
  -isohybrid-gpt-basdat \
  .

# 7. Conclusion
echo -e "${GREEN}[√] GENESIS FORGE COMPLETE.${RESET}"
echo -e "${CYAN}[*] Golden Master created: StormRaven-OS-Leviathan.iso${RESET}"
sudo umount "$WORK_DIR/iso"
rm -rf "$WORK_DIR"
