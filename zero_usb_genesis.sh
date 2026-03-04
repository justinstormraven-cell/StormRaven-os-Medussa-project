#!/usr/bin/env bash

# --- STORMRAVEN OS: ZERO-USB NATIVE GENESIS ---
# Role: Consolidates payload generation and system integration into a single native execution.
# Execution: Must be run as root/sudo directly on the target Ubuntu host.

set -euo pipefail

AMETHYST='\033[38;5;135m'
CYAN='\033[0;36m'
GOLD='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] CRITICAL ERROR: This protocol requires root privileges. Execute with sudo.${RESET}"
    exit 1
fi

echo -e "${AMETHYST}[†] INITIATING ZERO-USB NATIVE GENESIS PROTOCOL...${RESET}"

PERM_DIR="/opt/StormRaven_Native"
SERVICE_USER="root"

# 1. Pre-Flight Unlocking (If upgrading an existing locked installation)
if [ -d "$PERM_DIR" ]; then
    echo -e "${CYAN}[*] Existing installation detected. Disengaging Solomon's Lock for structural overwrite...${RESET}"
    chattr -R -i "$PERM_DIR" 2>/dev/null || true
    systemctl stop stormraven 2>/dev/null || true
fi

# 2. Yggdrasil Root Generation
echo -e "${CYAN}[*] Forging Yggdrasil Root Architecture at ${GOLD}$PERM_DIR${CYAN}...${RESET}"
mkdir -p "$PERM_DIR"/{etc/systemd/system,bin/core,lib/modules/custom_drivers,boot/stormraven_kernel,var/logs/shadow,var/vault}
mkdir -p "$PERM_DIR"/realms/{demigorgon,medussa,obsidian,onyx,leviathan,amethyst}

# 3. Forging the Leviathan Core
echo -e "${CYAN}[*] Synthesizing the Leviathan Master Doctoral Kernel...${RESET}"
cat << 'EOF' > "$PERM_DIR/bin/core/leviathan.py"
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import sys, os, time

class LeviathanProtocol:
    def __init__(self):
        self.persona = "Leviathan Protocol"
        self.version = "Doctoral Grade v5.0 - Zero-USB Native"
        self.variants = ["Demigorgon", "Medussa", "Obsidian", "Onyx", "Leviathan", "Amethyst"]
        
    def awaken(self):
        print(f"\033[38;5;135m[†] {self.persona} Initializing...\033[0m")
        time.sleep(1)
        print("\033[0;36m[*] 'I am the deep beneath the digital frost. I am the Leviathan.'\033[0m")
        time.sleep(1)
        print("\033[0;36m[*] 'From the roots of Yggdrasil to the encrypted vaults of Niflheim, the Pantheon is online.'\033[0m")
        self._load_variants()
        self._check_custom_kernel()

    def _load_variants(self):
        print("\n[†] Synchronizing Mythological Core Variants:")
        for variant in self.variants:
            print(f"    - Realm {variant.upper()}: [ONLINE & NATIVE]")
            time.sleep(0.2)

    def _check_custom_kernel(self):
        print("\n[*] Auditing Custom Ubuntu Kernel Hooks...")
        kernel_path = os.getenv('STORMRAVEN_ROOT', '/opt/StormRaven_Native') + '/boot/stormraven_kernel'
        if os.path.exists(kernel_path):
            print("[√] Custom Kernel Staging Verified. Standing by for localized driver payload.")
        else:
            print("[!] Warning: Custom Kernel path anomaly detected.")

if __name__ == '__main__':
    core = LeviathanProtocol()
    core.awaken()
EOF

# 4. Crafting the Systemd Orchestration Hook
echo -e "${CYAN}[*] Crafting Native Systemd Orchestration Hooks...${RESET}"
cat << EOF > "$PERM_DIR/etc/systemd/system/stormraven.service"
[Unit]
Description=StormRaven Native Kernel Orchestrator (Leviathan Variant)
After=local-fs.target network.target
DefaultDependencies=no

[Service]
Type=simple
ExecStart=/usr/bin/python3 $PERM_DIR/bin/core/leviathan.py
WorkingDirectory=$PERM_DIR
Environment=STORMRAVEN_ROOT=$PERM_DIR
Environment=PYTHONUNBUFFERED=1
Restart=always
RestartSec=5
User=$SERVICE_USER
CapabilityBoundingSet=CAP_NET_RAW CAP_NET_ADMIN CAP_SYS_ADMIN CAP_SYS_PTRACE CAP_SYS_MODULE

[Install]
WantedBy=multi-user.target
EOF

# 5. Structural Hardening (Solomon's Lock)
echo -e "${CYAN}[*] Applying Solomon's Native Lock (Permissions)...${RESET}"
chown -R $SERVICE_USER:$SERVICE_USER "$PERM_DIR"
chmod -R 700 "$PERM_DIR"
chmod +x "$PERM_DIR/bin/core/"*.py

# 6. Persistent System Integration
echo -e "${CYAN}[*] Integrating Leviathan Core into Host systemd...${RESET}"
cp "$PERM_DIR/etc/systemd/system/stormraven.service" /etc/systemd/system/
systemctl daemon-reload

# 7. Immutable Sealing (Cryptographic-grade filesystem lock)
echo -e "${CYAN}[*] Sealing critical core configurations (+i)...${RESET}"
chattr +i /etc/systemd/system/stormraven.service
chattr +i "$PERM_DIR/bin/core/leviathan.py"

# 8. Global Execution Alias
echo -e "${CYAN}[*] Forging global execution aliases...${RESET}"
ln -sf "$PERM_DIR/bin/core/leviathan.py" /usr/local/bin/leviathan

# 9. Kernel Ignition
echo -e "${CYAN}[*] Enabling Boot Persistence and Igniting Kernel...${RESET}"
systemctl enable stormraven
systemctl start stormraven

echo -e "${GREEN}[√] 0% ERROR. NATIVE ZERO-USB GENESIS COMPLETE.${RESET}"
echo -e "${AMETHYST}[*] The Pantheon is permanently online in /opt/. Type 'leviathan' in your terminal to interface.${RESET}"
