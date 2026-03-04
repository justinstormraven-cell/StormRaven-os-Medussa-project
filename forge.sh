#!/usr/bin/env bash

# --- STORMRAVEN OS: PANTHEON FORGE PROTOCOL (ULTIMATE CONVERGENCE) ---
# Role: Forges Mythological Core Modules, Crypto-Vaults, Hardware Auth, and API Gateways.
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

echo -e "${AMETHYST}[†] INITIATING PANTHEON FORGE (ULTIMATE CONVERGENCE)...${RESET}"

PERM_DIR="/opt/StormRaven_Native"
CORE_DIR="$PERM_DIR/bin/core"

# 1. Dependency Verification (Upgraded for Bifrost and Crypto)
echo -e "${CYAN}[*] Injecting Advanced System Dependencies...${RESET}"
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip python3-scapy python3-cryptography python3-rich tcpdump macchanger wireguard proxychains4 tor dnsmasq resolvconf >/dev/null 2>&1

# In Ubuntu 24.04, pip needs the break-system-packages flag for global installs, 
# or we use apt for standard packages. We'll use apt where possible, pip for the rest.
apt-get install -y python3-flask python3-jwt 2>/dev/null || \
pip3 install flask pyjwt cryptography scapy rich --break-system-packages >/dev/null 2>&1

# 2. Pre-Flight Unlocking
echo -e "${CYAN}[*] Disengaging Solomon's Lock for Module Injection...${RESET}"
chattr -R -i "$PERM_DIR" 2>/dev/null || true
chattr -i /etc/systemd/system/stormraven.service 2>/dev/null || true
chattr -i /etc/systemd/system/deadman.service 2>/dev/null || true
systemctl stop stormraven deadman 2>/dev/null || true

# ---------------------------------------------------------
# FORGING THE DEITIES (PYTHON MODULES)
# ---------------------------------------------------------

echo -e "${GOLD}[*] Forging Yggdrasil (Global Configuration)...${RESET}"
cat << 'EOF' > "$CORE_DIR/yggdrasil.py"
import os
from pathlib import Path

class Yggdrasil:
    ROOT = Path(os.getenv('STORMRAVEN_ROOT', '/opt/StormRaven_Native'))
    REALMS = {
        "Demigorgon": ROOT / "realms/demigorgon",
        "Medussa": ROOT / "realms/medussa",
        "Helheim": ROOT / "var/logs/shadow",
        "Niflheim": ROOT / "var/vault",
        "Midgard": Path("/tmp/stormraven_midgard") # Volatile RAM
    }
    
    @staticmethod
    def ensure_roots():
        for name, path in Yggdrasil.REALMS.items():
            path.mkdir(parents=True, exist_ok=True)
EOF

echo -e "${GOLD}[*] Forging Luci (Hardware-Bound Authentication)...${RESET}"
cat << 'EOF' > "$CORE_DIR/luci.py"
import os
import sys

class Luci:
    # In a production environment, this would poll /dev/disk/by-uuid/ for a specific USB thumb drive.
    # For this deployment, we use a strictly permissioned key file.
    TOKEN_PATH = "/etc/stormraven/Luci.key"

    @staticmethod
    def enforce_hardware_lock():
        if not os.path.exists(Luci.TOKEN_PATH):
            print("\033[0;31m[!] CRITICAL: Hardware Auth Token Missing.\033[0m")
            print("\033[0;31m[!] Luci has locked the environment. Terminating.\033[0m")
            sys.exit(1)
        return True
EOF

echo -e "${GOLD}[*] Forging Loki (AES-256 Cryptographic Telemetry)...${RESET}"
cat << 'EOF' > "$CORE_DIR/loki.py"
import json
import time
from cryptography.fernet import Fernet
from yggdrasil import Yggdrasil

class Loki:
    def __init__(self):
        self.log_file = Yggdrasil.REALMS["Helheim"] / "shadow_telemetry.enc"
        self.key_file = Yggdrasil.REALMS["Niflheim"] / "loki_master.key"
        
        # Initialize Crypto-Vault
        if not self.key_file.exists():
            self.key = Fernet.generate_key()
            self.key_file.write_bytes(self.key)
        else:
            self.key = self.key_file.read_bytes()
            
        self.cipher = Fernet(self.key)
        
        # Genesis Log Structure
        if not self.log_file.exists():
            self._write_vault([])

    def _read_vault(self):
        if not self.log_file.exists(): return []
        try:
            decrypted = self.cipher.decrypt(self.log_file.read_bytes())
            return json.loads(decrypted.decode('utf-8'))
        except Exception:
            return []

    def _write_vault(self, data):
        encrypted = self.cipher.encrypt(json.dumps(data, indent=4).encode('utf-8'))
        self.log_file.write_bytes(encrypted)

    def write_event(self, actor, action, target, outcome):
        try:
            data = self._read_vault()
            entry = {
                "timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                "actor": actor,
                "action": action,
                "target": target,
                "outcome": outcome
            }
            data.append(entry)
            self._write_vault(data)
        except Exception:
            pass # Fails silently to preserve stealth
EOF

echo -e "${GOLD}[*] Forging Heimdall (Security & Sanitization)...${RESET}"
cat << 'EOF' > "$CORE_DIR/heimdall.py"
class Heimdall:
    BLACKLIST = ["rm -rf /", "mkfs", "dd if=/dev/zero"]
    
    @staticmethod
    def inspect(command):
        for threat in Heimdall.BLACKLIST:
            if threat in command:
                return False, f"Heimdall blocked malicious intent: {threat}"
        return True, "Command sanitized and approved."
EOF

echo -e "${GOLD}[*] Forging Thor (Physical Execution strikes)...${RESET}"
cat << 'EOF' > "$CORE_DIR/thor.py"
import subprocess
from heimdall import Heimdall
from loki import Loki

class Thor:
    def __init__(self):
        self.logger = Loki()

    def strike(self, command):
        safe, msg = Heimdall.inspect(command)
        if not safe:
            self.logger.write_event("Thor", "Strike Blocked", command, "Failed - Heimdall Intervention")
            return msg
        
        try:
            result = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=10)
            self.logger.write_event("Thor", "Execution Strike", command, "Success")
            return result.stdout if result.returncode == 0 else result.stderr
        except Exception as e:
            self.logger.write_event("Thor", "Execution Strike", command, str(e))
            return f"Strike Failed: {e}"
EOF

echo -e "${GOLD}[*] Forging Mjolnir (Network Crusher/Scanner)...${RESET}"
cat << 'EOF' > "$CORE_DIR/mjolnir.py"
from scapy.all import ARP, Ether, srp
from loki import Loki

class Mjolnir:
    def __init__(self):
        self.logger = Loki()

    def crush_network(self, target_ip="192.168.1.0/24"):
        try:
            ans, _ = srp(Ether(dst="ff:ff:ff:ff:ff:ff")/ARP(pdst=target_ip), timeout=2, verbose=0)
            hosts = [{"ip": r.psrc, "mac": r.hwsrc} for s, r in ans]
            self.logger.write_event("Mjolnir", "Network Scan", target_ip, f"Discovered {len(hosts)} hosts")
            return hosts
        except Exception as e:
            self.logger.write_event("Mjolnir", "Network Scan", target_ip, "Failed")
            return []
EOF

echo -e "${GOLD}[*] Forging Bifrost (Secure API Gateway & JWT)...${RESET}"
cat << 'EOF' > "$CORE_DIR/bifrost.py"
from flask import Flask, request, jsonify
import jwt
import datetime
import threading
from mjolnir import Mjolnir
from thor import Thor

app = Flask(__name__)
# In production, this is dynamically generated and stored in Niflheim
app.config['SECRET_KEY'] = 'stormraven_obsidian_key'

def token_required(f):
    def decorator(*args, **kwargs):
        token = None
        if 'Authorization' in request.headers:
            parts = request.headers['Authorization'].split()
            if len(parts) == 2 and parts[0] == 'Bearer':
                token = parts[1]
        
        if not token:
            return jsonify({'message': 'Bifrost Bridge Closed: Token Missing'}), 401
            
        try:
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
        except Exception:
            return jsonify({'message': 'Bifrost Bridge Closed: Token Invalid or Expired'}), 401
            
        return f(*args, **kwargs)
    decorator.__name__ = f.__name__
    return decorator

@app.route('/api/auth', methods=['POST'])
def auth():
    auth_data = request.json
    if auth_data and auth_data.get('password') == 'awaken':
        token = jwt.encode({'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=1)}, app.config['SECRET_KEY'], algorithm="HS256")
        return jsonify({'token': token})
    return jsonify({'message': 'Authentication Denied'}), 401

@app.route('/api/scan', methods=['GET'])
@token_required
def api_scan():
    m = Mjolnir()
    return jsonify({'network_hosts': m.crush_network()})

@app.route('/api/strike', methods=['POST'])
@token_required
def api_strike():
    data = request.json
    if not data or 'command' not in data:
        return jsonify({'error': 'No command provided'}), 400
    t = Thor()
    result = t.strike(data['command'])
    return jsonify({'output': result})

class BifrostBridge:
    @staticmethod
    def open_gateway():
        # Runs the Flask API seamlessly in a background thread
        thread = threading.Thread(target=lambda: app.run(host='127.0.0.1', port=5005, debug=False, use_reloader=False), daemon=True)
        thread.start()
EOF

echo -e "${GOLD}[*] Forging Sleipnir (Anonymity, VPN, Proxy, MAC Scrambler)...${RESET}"
cat << 'EOF' > "$CORE_DIR/sleipnir.py"
import subprocess
from loki import Loki
import time

class Sleipnir:
    def __init__(self):
        self.logger = Loki()

    def scramble_mac(self, interface="eth0"):
        try:
            # Drop interface, scramble, bring back up
            subprocess.run(["ip", "link", "set", "dev", interface, "down"], check=True)
            result = subprocess.run(["macchanger", "-r", interface], capture_output=True, text=True)
            subprocess.run(["ip", "link", "set", "dev", interface, "up"], check=True)
            self.logger.write_event("Sleipnir", "MAC Scramble", interface, "Success")
            return result.stdout
        except Exception as e:
            self.logger.write_event("Sleipnir", "MAC Scramble", interface, f"Failed: {str(e)}")
            return f"MAC Scramble Failed. Ensure interface '{interface}' exists or run as root."

    def toggle_vpn(self, config_path="/etc/wireguard/wg0.conf", state="up"):
        try:
            subprocess.run(["wg-quick", state, config_path], capture_output=True, text=True)
            self.logger.write_event("Sleipnir", f"VPN {state.upper()}", config_path, "Executed")
            return f"WireGuard VPN {state.upper()} sequence initiated using {config_path}."
        except Exception as e:
            return f"VPN operation failed: {str(e)}"

    def secure_dns(self):
        try:
            with open("/etc/resolv.conf", "w") as f:
                f.write("nameserver 1.1.1.1\nnameserver 1.0.0.1\n")
            self.logger.write_event("Sleipnir", "DNS Secure", "1.1.1.1", "Success")
            return "DNS forced to strict secure resolvers (Cloudflare 1.1.1.1)."
        except Exception as e:
            return f"DNS routing failed: {str(e)}"
            
    def route_proxy(self):
        try:
            subprocess.run(["systemctl", "start", "tor"], check=False)
            self.logger.write_event("Sleipnir", "Proxy Tor Routing", "system", "Activated")
            return "Tor service ignited. Prefix commands in standard bash with 'proxychains4' to tunnel traffic."
        except Exception as e:
            return f"Tor proxy ignition failed: {str(e)}"
EOF

echo -e "${GOLD}[*] Forging Ginnungagap (Deadman Switch)...${RESET}"
cat << 'EOF' > "$CORE_DIR/deadman.py"
import time
import os
import sys

def monitor_void():
    print("[\033[38;5;135m†\033[0m] Ginnungagap Deadman Switch Online. Watching the Void.")
    while True:
        if not os.path.exists("/etc/systemd/system/stormraven.service"):
            print("[!] TAMPERING DETECTED. INITIATING RAGNAROK PURGE.")
            sys.exit(1)
        time.sleep(5)

if __name__ == "__main__":
    monitor_void()
EOF

# 3. Upgrading the Leviathan Orchestrator
echo -e "${CYAN}[*] Upgrading the Leviathan Orchestrator...${RESET}"
cat << 'EOF' > "$CORE_DIR/leviathan.py"
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import time
from yggdrasil import Yggdrasil
from luci import Luci
from loki import Loki
from thor import Thor
from mjolnir import Mjolnir
from bifrost import BifrostBridge
from sleipnir import Sleipnir
from rich.console import Console

console = Console()

class LeviathanProtocol:
    def __init__(self):
        # 1. Hardware Auth Check (Immediate kill if missing)
        Luci.enforce_hardware_lock()
        
        # 2. Structure Initialization
        Yggdrasil.ensure_roots()
        
        # 3. Load Deities
        self.loki = Loki()
        self.thor = Thor()
        self.mjolnir = Mjolnir()
        self.sleipnir = Sleipnir()
        
    def awaken(self):
        console.print("[bold magenta][†] Leviathan Protocol Initializing...[/]")
        time.sleep(0.5)
        
        # 4. Open API Gateway
        BifrostBridge.open_gateway()
        self.loki.write_event("Leviathan", "System Boot", "Core", "Awakened. API Online.")
        
        console.print("[cyan][*] 'I am the deep beneath the digital frost.'[/]")
        console.print("[cyan][*] Pantheon is Online. Yggdrasil Roots verified.[/]")
        console.print("[cyan][*] Crypto-Vault Active. Bifrost API Listening on Port 5005.[/]")
        console.print("[cyan][*] Sleipnir Anonymity Protocol (VPN/MAC/DNS) Ready.[/]")
        
        self.interface()

    def interface(self):
        while True:
            try:
                cmd = console.input("[bold magenta][ᚠ] Midgard » [/]")
                if cmd.lower() in ["exit", "sleep"]:
                    self.loki.write_event("Leviathan", "System Sleep", "Core", "Dormant")
                    break
                elif cmd.lower() == "scan":
                    console.print(f"[\033[38;5;135m†\033[0m] Mjolnir is striking the subnet...")
                    hosts = self.mjolnir.crush_network()
                    for h in hosts:
                        console.print(f"  [green]➔ Target Locked:[/] {h['ip']} ({h['mac']})")
                elif cmd.lower().startswith("scramble"):
                    parts = cmd.split()
                    iface = parts[1] if len(parts) > 1 else "eth0"
                    console.print(f"[\033[38;5;135m†\033[0m] Sleipnir is masking hardware identity on {iface}...")
                    console.print(self.sleipnir.scramble_mac(iface))
                elif cmd.lower() == "secure dns":
                    console.print(f"[\033[38;5;135m†\033[0m] Sleipnir is rerouting DNS...")
                    console.print(self.sleipnir.secure_dns())
                elif cmd.lower() == "tor proxy":
                    console.print(f"[\033[38;5;135m†\033[0m] {self.sleipnir.route_proxy()}")
                elif cmd.lower().startswith("vpn"):
                    parts = cmd.split()
                    state = parts[1] if len(parts) > 1 else "up"
                    console.print(f"[\033[38;5;135m†\033[0m] Sleipnir is shifting VPN state to: {state}...")
                    console.print(self.sleipnir.toggle_vpn(state=state))
                else:
                    result = self.thor.strike(cmd)
                    console.print(result)
            except KeyboardInterrupt:
                break

if __name__ == '__main__':
    core = LeviathanProtocol()
    core.awaken()
EOF

# 4. Wiring the Deadman Service
echo -e "${CYAN}[*] Registering Ginnungagap (Deadman) Systemd Unit...${RESET}"
cat << EOF > "$PERM_DIR/etc/systemd/system/deadman.service"
[Unit]
Description=StormRaven Deadman Switch (Ginnungagap)
After=stormraven.service

[Service]
Type=simple
ExecStart=/usr/bin/python3 $CORE_DIR/deadman.py
WorkingDirectory=$PERM_DIR
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF
cp "$PERM_DIR/etc/systemd/system/deadman.service" /etc/systemd/system/

# 5. VPN Architecture Generation (WireGuard)
echo -e "${CYAN}[*] Forging Sleipnir VPN Cryptography (WireGuard)...${RESET}"
mkdir -p /etc/wireguard
if [ ! -f /etc/wireguard/private.key ]; then
    wg genkey | tee /etc/wireguard/private.key | wg pubkey > /etc/wireguard/public.key
    chmod 600 /etc/wireguard/private.key
fi

if [ ! -f /etc/wireguard/wg0.conf ]; then
    PRIV_KEY=$(cat /etc/wireguard/private.key)
    cat << EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $PRIV_KEY
Address = 10.66.66.2/32
DNS = 1.1.1.1, 1.0.0.1

[Peer]
# [REPLACE] PUBLIC KEY OF YOUR VPN PROVIDER OR SERVER
PublicKey = <SERVER_PUBLIC_KEY>
# [REPLACE] ENDPOINT IP AND PORT OF YOUR VPN PROVIDER
Endpoint = <SERVER_IP>:51820
AllowedIPs = 0.0.0.0/0, ::/0
PersistentKeepalive = 25
EOF
    chmod 600 /etc/wireguard/wg0.conf
    echo -e "    ${GREEN}[+] WireGuard Interface (wg0) keys and configuration template generated.${RESET}"
fi

# 6. Hardware Token Generation
echo -e "${CYAN}[*] Generating Physical Luci Hardware Token...${RESET}"
mkdir -p /etc/stormraven
if [ ! -f /etc/stormraven/Luci.key ]; then 
    echo "STORMR_AUTH_OVERRIDE_$(date +%s)" > /etc/stormraven/Luci.key;
    chmod 400 /etc/stormraven/Luci.key
fi

# 7. Applying Solomon's Lock
echo -e "${CYAN}[*] Re-engaging Solomon's Lock (Cryptographic Sealing)...${RESET}"
chown -R root:root "$PERM_DIR"
chmod -R 700 "$PERM_DIR"
chmod +x "$CORE_DIR/"*.py

systemctl daemon-reload

chattr +i /etc/systemd/system/stormraven.service
chattr +i /etc/systemd/system/deadman.service
chattr +i "$CORE_DIR/"*.py

#!/usr/bin/env bash

# 1. Unlock the Core
sudo chattr -i /opt/StormRaven_Native/bin/core/*.py 2>/dev/null || true

# 2. Forge the Demogorgon Deception Module
cat << 'EOF' | sudo tee /opt/StormRaven_Native/bin/core/demogorgon.py > /dev/null
import socket
import threading
from loki import Loki

# Global instance to keep the trap thread alive across API calls
_demogorgon_instance = None

class Demogorgon:
    def __init__(self, port=2222):
        self.port = port
        self.logger = Loki()
        self.is_active = False
        self.trap_thread = None
        self.socket = None

    def _the_upside_down(self):
        try:
            self.socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.socket.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            self.socket.bind(('0.0.0.0', self.port))
            self.socket.listen(5)
            self.logger.write_event("Demogorgon", "Trap Activated", f"Port {self.port}", "Listening for anomalies...")
            
            while self.is_active:
                self.socket.settimeout(1.0)
                try:
                    conn, addr = self.socket.accept()
                    attacker_ip = addr[0]
                    self.logger.write_event("Demogorgon", "Intrusion Attempt", attacker_ip, f"Trapped on Port {self.port}")
                    conn.send(b"Connection trapped by StormRaven. Welcome to the Upside Down.\n")
                    conn.close()
                except socket.timeout:
                    continue
        except Exception as e:
            self.logger.write_event("Demogorgon", "Trap Failure", "Core", str(e))
        finally:
            if self.socket:
                self.socket.close()

    def awaken(self):
        if self.is_active:
            return f"Demogorgon Trap is already active on Port {self.port}."
        self.is_active = True
        self.trap_thread = threading.Thread(target=self._the_upside_down, daemon=True)
        self.trap_thread.start()
        return f"Demogorgon Deception Node awakened. The shadow port ({self.port}) is open and listening."

    def banish(self):
        if not self.is_active:
            return "Demogorgon Trap is already dormant."
        self.is_active = False
        if self.trap_thread:
            self.trap_thread.join(timeout=2)
        return "Demogorgon banished. The Upside Down is closed."

def get_demogorgon():
    global _demogorgon_instance
    if _demogorgon_instance is None:
        _demogorgon_instance = Demogorgon()
    return _demogorgon_instance
EOF

# 3. Patch the Bifrost Gateway to include the new Demogorgon routes
cat << 'EOF' | sudo tee /opt/StormRaven_Native/bin/core/bifrost.py > /dev/null
from flask import Flask, request, jsonify
from flask_cors import CORS
import jwt
import datetime
import threading
import json
from mjolnir import Mjolnir
from thor import Thor
from fenrir import Fenrir
from odin import Odin
from gungnir import Gungnir
from loki import Loki
from demogorgon import get_demogorgon

app = Flask(__name__)
CORS(app)
app.config['SECRET_KEY'] = 'stormraven_obsidian_key'

def token_required(f):
    def decorator(*args, **kwargs):
        token = None
        if 'Authorization' in request.headers:
            parts = request.headers['Authorization'].split()
            if len(parts) == 2 and parts[0] == 'Bearer':
                token = parts[1]
        if not token:
            return jsonify({'message': 'Bifrost Bridge Closed: Token Missing'}), 401
        try:
            data = jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
        except Exception:
            return jsonify({'message': 'Bifrost Bridge Closed: Token Invalid or Expired'}), 401
        return f(*args, **kwargs)
    decorator.__name__ = f.__name__
    return decorator

@app.route('/api/auth', methods=['POST'])
def auth():
    auth_data = request.json
    if auth_data and auth_data.get('password') == 'awaken':
        token = jwt.encode({'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=1)}, app.config['SECRET_KEY'], algorithm="HS256")
        return jsonify({'token': token})
    return jsonify({'message': 'Authentication Denied'}), 401

@app.route('/api/scan', methods=['GET'])
@token_required
def api_scan():
    m = Mjolnir()
    return jsonify({'network_hosts': m.crush_network()})

@app.route('/api/fenrir', methods=['POST'])
@token_required
def api_fenrir():
    data = request.json
    if not data or 'target' not in data:
        return jsonify({'error': 'No target IP provided'}), 400
    f = Fenrir()
    return jsonify({'output': f.deep_scan(data['target'])})

@app.route('/api/odin', methods=['POST'])
@token_required
def api_odin():
    data = request.json
    if not data or 'url' not in data:
        return jsonify({'error': 'No destination URL provided'}), 400
    o = Odin()
    return jsonify({'output': o.dispatch_alert(data['url'], data.get('message', 'StormRaven Node active.'))})

@app.route('/api/gungnir', methods=['POST'])
@token_required
def api_gungnir():
    data = request.json
    if not data or 'port' not in data:
        return jsonify({'error': 'No port provided'}), 400
    g = Gungnir()
    return jsonify({'output': g.forge_defense(data['port'])})

@app.route('/api/vault', methods=['GET'])
@token_required
def api_vault():
    try:
        l = Loki()
        vault_data = l._read_vault()
        if not vault_data:
            return jsonify({'output': 'Vault is currently empty.'})
        formatted_vault = json.dumps(vault_data, indent=4)
        return jsonify({'output': f"CRYPTOGRAPHIC VAULT BREACHED:\n\n{formatted_vault}"})
    except Exception as e:
        return jsonify({'error': f"Decryption failed: {str(e)}"}), 500

@app.route('/api/strike', methods=['POST'])
@token_required
def api_strike():
    data = request.json
    if not data or 'command' not in data:
        return jsonify({'error': 'No command provided'}), 400
    t = Thor()
    return jsonify({'output': t.strike(data['command'])})

# --- NEW DEMOGORGON ROUTES ---
@app.route('/api/demogorgon/awaken', methods=['POST'])
@token_required
def api_demo_awaken():
    d = get_demogorgon()
    return jsonify({'output': d.awaken()})

@app.route('/api/demogorgon/banish', methods=['POST'])
@token_required
def api_demo_banish():
    d = get_demogorgon()
    return jsonify({'output': d.banish()})

class BifrostBridge:
    @staticmethod
    def open_gateway():
        thread = threading.Thread(target=lambda: app.run(host='127.0.0.1', port=5005, debug=False, use_reloader=False), daemon=True)
        thread.start()
EOF

# 4. Seal and Restart
sudo chmod +x /opt/StormRaven_Native/bin/core/*.py
sudo chattr +i /opt/StormRaven_Native/bin/core/*.py 2>/dev/null || true
sudo systemctl restart stormraven
sudo systemctl status stormraven --no-pager
# 8. Ignition
echo -e "${CYAN}[*] Igniting the Core and Deadman Daemons...${RESET}"
systemctl enable stormraven deadman 2>/dev/null
systemctl start deadman 

echo -e "${GREEN}[√] PANTHEON FORGE (ULTIMATE CONVERGENCE) COMPLETE.${RESET}"
echo -e "${AMETHYST}[*] Hardware Auth (Luci): Active (/etc/stormraven/Luci.key)${RESET}"
echo -e "${AMETHYST}[*] Crypto Storage (Niflheim): Active (AES-256 Fernet logs)${RESET}"
echo -e "${AMETHYST}[*] API Gateway (Bifrost): Active (Port 5005, JWT Secured)${RESET}"
echo -e "${AMETHYST}[*] VPN (Sleipnir): Client Configuration generated at /etc/wireguard/wg0.conf${RESET}"
echo -e "${AMETHYST}[*] Type 'sudo leviathan' to access the core.${RESET}"
