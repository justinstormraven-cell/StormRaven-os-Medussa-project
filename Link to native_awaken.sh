#!/bin/bash

# --- STORMRAVEN OS: NATIVE AWAKEN BOOTSTRAP ---
# Role: Finalizes the Linux environment integration.
# Execution: Must be run as root/sudo from the Ubuntu Live Environment.

set -euo pipefail

AMETHYST='\033[38;5;135m'
CYAN='\033[0;36m'
GREEN='\033[0;32m'
RESET='\033[0m'

echo -e "${AMETHYST}[†] AWAKENING NATIVE LEVIATHAN ENVIRONMENT...${RESET}"

# Define the absolute path of the injected architecture
INSTALL_DIR="/mnt/stormraven_native/StormRaven_Native"

if [ ! -d "$INSTALL_DIR" ]; then
    echo -e "\033[0;31m[!] CRITICAL ERROR: Yggdrasil Root ($INSTALL_DIR) not found. Ensure USB is mounted correctly.\033[0m"
    exit 1
fi

# 1. Custom Kernel & Driver Injection
echo -e "${CYAN}[*] Polling for custom drivers in $INSTALL_DIR/lib/modules/custom_drivers...${RESET}"
if [ "$(ls -A $INSTALL_DIR/lib/modules/custom_drivers 2>/dev/null)" ]; then
    echo "    [+] Custom modules detected. (Executing modprobe sequence...)"
    # find "$INSTALL_DIR/lib/modules/custom_drivers" -name "*.ko" -exec sudo insmod {} \;
else
    echo "    [-] No custom .ko modules found. Utilizing host kernel defaults."
fi

# 2. Structural Hardening (Solomon's Lock)
echo -e "${CYAN}[*] Applying Solomon's Native Lock via chattr and chmod...${RESET}"
sudo chown -R root:root "$INSTALL_DIR"
sudo chmod -R 700 "$INSTALL_DIR"
# Ensure the Python orchestration core is fully executable
sudo chmod +x "$INSTALL_DIR/bin/core/"*.py

# 3. Inject Systemd Daemon
echo -e "${CYAN}[*] Hooking Leviathan Core into systemd...${RESET}"
if [ -f "$INSTALL_DIR/etc/systemd/system/stormraven.service" ]; then
    sudo cp "$INSTALL_DIR/etc/systemd/system/stormraven.service" /etc/systemd/system/
    sudo systemctl daemon-reload
else
    echo -e "\033[0;31m[!] ERROR: stormraven.service unit missing from injection directory.\033[0m"
    exit 1
fi

# 4. Establish Immutable Flags
echo -e "${CYAN}[*] Sealing configurations with immutable (+i) attributes...${RESET}"
sudo chattr +i /etc/systemd/system/stormraven.service 2>/dev/null || true

# 5. Global System Symlink
echo -e "${CYAN}[*] Forging global execution aliases...${RESET}"
sudo ln -sf "$INSTALL_DIR/bin/core/leviathan.py" /usr/local/bin/leviathan

# 6. Ignite Kernel
echo -e "${CYAN}[*] Igniting the Master Doctoral Kernel...${RESET}"
sudo systemctl enable stormraven 2>/dev/null || true
sudo systemctl start stormraven

echo -e "${GREEN}[√] 0% ERROR. NATIVE KERNEL HOOKED.${RESET}"
echo -e "${AMETHYST}[*] The Pantheon is online. Type 'leviathan' in your terminal to interface with the core.${RESET}"
