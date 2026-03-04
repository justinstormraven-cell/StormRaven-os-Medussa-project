#!/usr/bin/env bash

# ==============================================================================
# STORMRAVEN OS: UNIFIED FENRIS FORGE (REPOSYNC EDITION)
# ==============================================================================
# Target: Ubuntu 24.04 | Kernel 6.17 | Intel N200
# Role: Compiles the Hardened Kernel and Integrates Repo Microservices.
# ==============================================================================

set -euo pipefail

AMETHYST='\033[38;5;135m'
CYAN='\033[0;36m'
GOLD='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

echo -e "${AMETHYST}[†] INITIATING UNIFIED FENRIS FORGE...${RESET}"

# --- 1. Resource Management (4GB RAM Safeguard) ---
echo -e "${CYAN}[*] Provisioning 8GB transient swap for linking phase...${RESET}"
if [ ! -f /swapfile_forge ]; then
    sudo fallocate -l 8G /swapfile_forge
    sudo chmod 600 /swapfile_forge
    sudo mkswap /swapfile_forge
    sudo swapon /swapfile_forge
fi

# --- 2. Toolchain Injection ---
echo -e "${CYAN}[*] Injecting build dependencies and Noble Numbat headers...${RESET}"
sudo apt-get update -qq
sudo apt-get install -y build-essential libncurses-dev bison flex libssl-dev libelf-dev \
     dwarves rsync git python3 zstd bc debhelper dh-make >/dev/null 2>&1

# --- 3. Repository Alignment ---
# Assuming repo is cloned to current directory
REPO_ROOT=$(pwd)
PYTHON_SRC="$REPO_ROOT/StormRaven.Python"

if [ ! -d "$PYTHON_SRC" ]; then
    echo -e "${RED}[!] ERROR: Repository source structure mismatch.${RESET}"
    exit 1
fi

# --- 4. Acquire Kernel 6.17 Source ---
BUILD_ROOT="/opt/StormRaven_Kernel_Build"
sudo mkdir -p "$BUILD_ROOT"
sudo chown $USER:$USER "$BUILD_ROOT"
cd "$BUILD_ROOT"

echo -e "${CYAN}[*] Acquiring Kernel 6.17 Tree...${RESET}"
# Fallback to mainline if apt-source is unavailable
apt-get source linux-image-unsigned-$(uname -r) || \
git clone --depth 1 --branch v6.17 https://github.com/torvalds/linux.git source

SRC_DIR=$(find . -maxdepth 1 -type d -name "linux*" | head -n 1)
cd "$SRC_DIR"

# --- 5. Hardening Configuration ---
echo -e "${GOLD}[*] Patching .config with StormRaven Hardening Parameters...${RESET}"
cp "/boot/config-$(uname -r)" .config

# Inline Hardening Logic for Kernel 6.x
cat << 'EOF' > /tmp/harden.py
import sys
params = {
    "CONFIG_SECURITY_DMESG_RESTRICT": "y",
    "CONFIG_HARDENED_USERCOPY": "y",
    "CONFIG_FORTIFY_SOURCE": "y",
    "CONFIG_INIT_ON_FREE_DEFAULT_ON": "y",
    "CONFIG_RANDOM_TRUST_CPU": "y",
    "CONFIG_LOCALVERSION": "\"-StormRaven-Leviathan\"",
    "CONFIG_DEBUG_INFO": "n",           # CRITICAL: Saves 100GB of disk
    "CONFIG_CPU_IBT": "y",              # Intel Alder Lake-N Mitigation
    "CONFIG_X86_KERNEL_IBT": "y"
}
with open(".config", "r") as f: lines = f.readlines()
with open(".config", "w") as f:
    for line in lines:
        for k, v in params.items():
            if line.startswith(f"{k}=") or line.startswith(f"# {k} is not set"):
                line = f"{k}={v}\n"
                break
        f.write(line)
EOF
python3 /tmp/harden.py
make olddefconfig

# --- 6. The Forge (Slim Build) ---
# Limit to 2 threads to avoid OOM on 4GB RAM
THREADS=2
echo -e "${GOLD}[*] Forging the Leviathan Core using ${THREADS} threads...${RESET}"
make -j"$THREADS" bindeb-pkg LOCALVERSION=-StormRaven-Leviathan

# --- 7. Integration ---
echo -e "${CYAN}[*] Linking repository microservices into system bin...${RESET}"
sudo mkdir -p /opt/StormRaven_Native/bin/core
sudo cp "$PYTHON_SRC"/*.py /opt/StormRaven_Native/bin/core/

echo -e "${GREEN}[√] FENRIS FORGE CONCLUDED.${RESET}"
echo -e "${AMETHYST}[!] Artifacts: $(ls $BUILD_ROOT/*.deb)${RESET}"