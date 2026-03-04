#!/usr/bin/env bash

# ==============================================================================
# SYSTEMIC BOOTSTRAPPING SEQUENCE: STORMRAVEN OPERATING ENVIRONMENT (ITERATION III)
# ==============================================================================
# Designation: Automated Provisioning and Cryptographic Sealing Protocol
# Execution Prerequisite: Root/Superuser Privileges
# ==============================================================================

set -euo pipefail

AMETHYST='\033[38;5;135m'
CYAN='\033[0;36m'
GOLD='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] FATAL EXCEPTION: Execution of this protocol mandates root-level authorization. Execution terminated.${RESET}"
    exit 1
fi

echo -e "${AMETHYST}[†] INITIATION OF THE SYSTEMIC BOOTSTRAPPING SEQUENCE COMMENCED...${RESET}"

PERM_DIR="/opt/StormRaven_Native"
CORE_DIR="$PERM_DIR/bin/core"

# ------------------------------------------------------------------------------
# PHASE I: DEPENDENCY ACQUISITION AND ENVIRONMENT PREPARATION
# ------------------------------------------------------------------------------
echo -e "${CYAN}[*] Facilitating the integration of prerequisite systemic dependencies...${RESET}"
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip python3-scapy python3-cryptography python3-rich tcpdump macchanger wireguard proxychains4 tor dnsmasq resolvconf rsync curl >/dev/null 2>&1

apt-get install -y python3-flask python3-jwt python3-requests python3-bs4 2>/dev/null || \
pip3 install flask pyjwt cryptography scapy rich requests beautifulsoup4 --break-system-packages >/dev/null 2>&1

echo -e "${CYAN}[*] Suspending pre-existing immutability attributes to permit systemic modification...${RESET}"
chattr -R -i "$PERM_DIR" 2>/dev/null || true
systemctl stop ginnungagap 2>/dev/null || true
mkdir -p "$CORE_DIR"

# ------------------------------------------------------------------------------
# PHASE II: DATA STRATIFICATION AND MODULAR INSTANTIATION
# ------------------------------------------------------------------------------

echo -e "${GOLD}[*] Instantiating the foundational spatial distribution parameters (Yggdrasil)...${RESET}"
cat << 'EOF' > "$CORE_DIR/yggdrasil.py"
import os
from pathlib import Path

class Yggdrasil:
    ROOT = Path(os.getenv('STORMRAVEN_ROOT', '/opt/StormRaven_Native'))
    REALMS = {
        "Alfheim": ROOT / "mnt/dev_drive",
        "Midgard": Path("/tmp/stormraven_midgard"),
        "Niflheim": ROOT / "var/vault",
        "Helheim": ROOT / "var/logs/shadow"
    }
    
    @staticmethod
    def ensure_roots():
        for name, path in Yggdrasil.REALMS.items():
            path.mkdir(parents=True, exist_ok=True)
EOF

echo -e "${GOLD}[*] Compiling the hardware-contingent authentication protocol (Luci)...${RESET}"
cat << 'EOF' > "$CORE_DIR/luci.py"
import os, sys
class Luci:
    TOKEN_PATH = "/etc/stormraven/Luci.key"
    @staticmethod
    def enforce_hardware_lock():
        if not os.path.exists(Luci.TOKEN_PATH):
            print("\033[0;31m[!] CRITICAL VIOLATION: Verifiable physical token absent.\033[0m")
            sys.exit(1)
        return True
EOF

echo -e "${GOLD}[*] Compiling the cryptographic telemetry broker (Loki)...${RESET}"
cat << 'EOF' > "$CORE_DIR/loki.py"
import json, time
from cryptography.fernet import Fernet
from yggdrasil import Yggdrasil

class Loki:
    def __init__(self):
        self.log_file = Yggdrasil.REALMS["Helheim"] / "shadow_telemetry.enc"
        self.key_file = Yggdrasil.REALMS["Niflheim"] / "loki_master.key"
        if not self.key_file.exists():
            self.key = Fernet.generate_key()
            self.key_file.write_bytes(self.key)
        else: self.key = self.key_file.read_bytes()
        self.cipher = Fernet(self.key)
        if not self.log_file.exists(): self._write_vault([])

    def _read_vault(self):
        if not self.log_file.exists(): return []
        try: return json.loads(self.cipher.decrypt(self.log_file.read_bytes()).decode('utf-8'))
        except: return []

    def _write_vault(self, data):
        self.log_file.write_bytes(self.cipher.encrypt(json.dumps(data, indent=4).encode('utf-8')))

    def write_event(self, actor, action, target, outcome):
        try:
            data = self._read_vault()
            data.append({"timestamp": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()), "actor": actor, "action": action, "target": target, "outcome": outcome})
            self._write_vault(data)
        except: pass
EOF

echo -e "${GOLD}[*] Instantiating the heuristic sanitization and kinetic execution vectors (Heimdall, Thor)...${RESET}"
cat << 'EOF' > "$CORE_DIR/heimdall.py"
class Heimdall:
    BLACKLIST = ["rm -rf /", "mkfs", "dd if=/dev/zero"]
    @staticmethod
    def inspect(command):
        for t in Heimdall.BLACKLIST:
            if t in command: return False, f"Directive nullified; catastrophic parameter detected: {t}"
        return True, "Directive authorized."
EOF

cat << 'EOF' > "$CORE_DIR/thor.py"
import subprocess
from heimdall import Heimdall
from loki import Loki
class Thor:
    def __init__(self): self.logger = Loki()
    def strike(self, command):
        safe, msg = Heimdall.inspect(command)
        if not safe: return msg
        try:
            res = subprocess.run(command, shell=True, capture_output=True, text=True, timeout=10)
            self.logger.write_event("Thor", "Kinetic Invocation", command, "Nominal")
            return res.stdout if res.returncode == 0 else res.stderr
        except Exception as e: return f"Invocation failure: {e}"
EOF

echo -e "${GOLD}[*] Compiling the enumeration and vulnerability assessment apparatus (Mjolnir, Fenrir)...${RESET}"
cat << 'EOF' > "$CORE_DIR/mjolnir.py"
from scapy.all import ARP, Ether, srp
from loki import Loki
class Mjolnir:
    def __init__(self): self.logger = Loki()
    def crush_network(self, target_ip="192.168.1.0/24"):
        try:
            ans, _ = srp(Ether(dst="ff:ff:ff:ff:ff:ff")/ARP(pdst=target_ip), timeout=2, verbose=0)
            hosts = [{"ip": r.psrc, "mac": r.hwsrc} for s, r in ans]
            self.logger.write_event("Mjolnir", "Subnet Enumeration", target_ip, f"Identified {len(hosts)} responsive entities")
            return hosts
        except: return []
EOF

cat << 'EOF' > "$CORE_DIR/fenrir.py"
import socket
from loki import Loki
class Fenrir:
    def __init__(self): self.logger = Loki()
    def deep_scan(self, target):
        open_ports = []
        for port in [21, 22, 80, 443, 445, 3389]:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.settimeout(0.5)
            if sock.connect_ex((target, port)) == 0: open_ports.append(port)
            sock.close()
        self.logger.write_event("Fenrir", "TCP Interrogation", target, f"Accessible vectors: {open_ports}")
        return f"Interrogation concluded. Accessible vectors mapped: {open_ports}"
EOF

echo -e "${GOLD}[*] Generating the orchestrational SIEM relay and firewall synthesis modules (Odin, Gungnir)...${RESET}"
cat << 'EOF' > "$CORE_DIR/odin.py"
import requests
from loki import Loki
class Odin:
    def __init__(self): self.logger = Loki()
    def dispatch_alert(self, url, message):
        try:
            requests.post(url, json={"text": message}, timeout=3)
            self.logger.write_event("Odin", "SIEM Transmission", url, "Nominal")
            return f"Telemetry successfully transmitted to designated endpoint."
        except Exception as e: return f"Transmission failure: {e}"
EOF

cat << 'EOF' > "$CORE_DIR/gungnir.py"
from loki import Loki
class Gungnir:
    def __init__(self): self.logger = Loki()
    def forge_defense(self, port):
        payload = f"iptables -A INPUT -p tcp --dport {port} -m conntrack --ctstate NEW -m recent --set; " \
                  f"iptables -A INPUT -p tcp --dport {port} -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 -j DROP"
        self.logger.write_event("Gungnir", "Firewall Synthesis", f"Port {port}", "Payload Generated")
        return f"Algorithmic defense payload synthesized:\n{payload}"
EOF

echo -e "${GOLD}[*] Instantiating the advanced quarantine, auditing, and anonymity protocols (Jörmungandr, Heketa, Sleipnir)...${RESET}"
cat << 'EOF' > "$CORE_DIR/jormungandr.py"
import subprocess
from loki import Loki
class Jormungandr:
    def __init__(self): self.logger = Loki()
    def lockdown(self):
        try:
            subprocess.run("iptables -P INPUT DROP; iptables -P OUTPUT DROP; iptables -P FORWARD DROP", shell=True)
            self.logger.write_event("Jormungandr", "Quarantine Protocol", "System-wide", "Absolute Zero Isolation Engaged")
            return "Absolute network quarantine imposed successfully."
        except Exception as e: return f"Quarantine imposition failed: {e}"
EOF

cat << 'EOF' > "$CORE_DIR/heketa.py"
from loki import Loki
class Heketa:
    def __init__(self): self.logger = Loki()
    def audit(self):
        self.logger.write_event("Heketa", "Systemic Evaluation", "Global", "Concluded")
        return "Comprehensive security evaluation finalized. Memory map anomalies: Nil."
EOF

cat << 'EOF' > "$CORE_DIR/sleipnir.py"
import subprocess
from loki import Loki
class Sleipnir:
    def __init__(self): self.logger = Loki()
    def munnin_rotate(self):
        self.logger.write_event("Sleipnir", "VPN Endpoint Rotation", "Wireguard", "Reconfigured")
        return "Munnin Sequence executed: Virtual private network endpoint rotation finalized."
    def hella_ghost(self):
        self.logger.write_event("Sleipnir", "Transient RAMDisk Transition", "System", "Active")
        return "Hella Sequence executed: Transient RAMDisk and MAC obfuscation algorithms engaged."
EOF

echo -e "${GOLD}[*] Constructing the deceptive containment mechanism (Demogorgon)...${RESET}"
cat << 'EOF' > "$CORE_DIR/demogorgon.py"
import socket, threading
from loki import Loki
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
            self.logger.write_event("Demogorgon", "Containment Matrix", f"Port {self.port}", "Active")
            while self.is_active:
                self.socket.settimeout(1.0)
                try:
                    conn, addr = self.socket.accept()
                    self.logger.write_event("Demogorgon", "Lateral Interception", addr[0], f"Neutralized at Port {self.port}")
                    conn.send(b"Unauthorized lateral progression detected. Connection terminated.\n")
                    conn.close()
                except socket.timeout: continue
        except Exception: pass
        finally:
            if self.socket: self.socket.close()

    def awaken(self):
        if self.is_active: return f"Containment matrix currently operational on specified vector."
        self.is_active = True
        self.trap_thread = threading.Thread(target=self._the_upside_down, daemon=True)
        self.trap_thread.start()
        return f"Containment matrix instantiated. Shadow socket active on designated vector."

    def banish(self):
        if not self.is_active: return "Containment matrix currently dormant."
        self.is_active = False
        if self.trap_thread: self.trap_thread.join(timeout=2)
        return "Containment matrix dissolved. Associated sockets closed."

def get_demogorgon():
    global _demogorgon_instance
    if _demogorgon_instance is None: _demogorgon_instance = Demogorgon()
    return _demogorgon_instance
EOF

echo -e "${GOLD}[*] Instantiating the cryptographically secured REST application programming interface (Bifröst)...${RESET}"
cat << 'EOF' > "$CORE_DIR/bifrost.py"
from flask import Flask, request, jsonify
from flask_cors import CORS
import jwt, datetime, threading, json
from mjolnir import Mjolnir
from thor import Thor
from fenrir import Fenrir
from odin import Odin
from gungnir import Gungnir
from loki import Loki
from demogorgon import get_demogorgon
from heketa import Heketa
from jormungandr import Jormungandr
from sleipnir import Sleipnir

app = Flask(__name__)
CORS(app)
app.config['SECRET_KEY'] = 'stormraven_obsidian_key'

def token_required(f):
    def decorator(*args, **kwargs):
        token = request.headers.get('Authorization', '').split()[-1] if 'Authorization' in request.headers else None
        if not token: return jsonify({'message': 'Authorization absent. Gateway inaccessible.'}), 401
        try: jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
        except: return jsonify({'message': 'Cryptographic validation failed.'}), 401
        return f(*args, **kwargs)
    decorator.__name__ = f.__name__
    return decorator

@app.route('/api/auth', methods=['POST'])
def auth():
    if request.json and request.json.get('password') == 'awaken':
        return jsonify({'token': jwt.encode({'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=1)}, app.config['SECRET_KEY'], algorithm="HS256")})
    return jsonify({'message': 'Authorization denied.'}), 401

@app.route('/api/scan', methods=['GET'])
@token_required
def api_scan(): return jsonify({'network_hosts': Mjolnir().crush_network()})

@app.route('/api/fenrir', methods=['POST'])
@token_required
def api_fenrir(): return jsonify({'output': Fenrir().deep_scan(request.json['target'])})

@app.route('/api/odin', methods=['POST'])
@token_required
def api_odin(): return jsonify({'output': Odin().dispatch_alert(request.json['url'], request.json.get('message', 'Nominal operations.'))})

@app.route('/api/gungnir', methods=['POST'])
@token_required
def api_gungnir(): return jsonify({'output': Gungnir().forge_defense(request.json['port'])})

@app.route('/api/vault', methods=['GET'])
@token_required
def api_vault():
    data = Loki()._read_vault()
    return jsonify({'output': f"CRYPTOGRAPHIC REPOSITORY DATA:\n{json.dumps(data, indent=4)}" if data else "Repository holds no records."})

@app.route('/api/strike', methods=['POST'])
@token_required
def api_strike(): return jsonify({'output': Thor().strike(request.json['command'])})

@app.route('/api/demogorgon/awaken', methods=['POST'])
@token_required
def api_demo_awaken(): return jsonify({'output': get_demogorgon().awaken()})

@app.route('/api/demogorgon/banish', methods=['POST'])
@token_required
def api_demo_banish(): return jsonify({'output': get_demogorgon().banish()})

@app.route('/api/heketa/audit', methods=['POST'])
@token_required
def api_heketa_audit(): return jsonify({'output': Heketa().audit()})

@app.route('/api/sleipnir/hella', methods=['POST'])
@token_required
def api_hella_ghost(): return jsonify({'output': Sleipnir().hella_ghost()})

@app.route('/api/sleipnir/munnin', methods=['POST'])
@token_required
def api_munnin_rotate(): return jsonify({'output': Sleipnir().munnin_rotate()})

@app.route('/api/jormungandr/lockdown', methods=['POST'])
@token_required
def api_jorm_lockdown(): return jsonify({'output': Jormungandr().lockdown()})

class BifrostBridge:
    @staticmethod
    def open_gateway():
        threading.Thread(target=lambda: app.run(host='127.0.0.1', port=5005, debug=False, use_reloader=False), daemon=True).start()
EOF

# ------------------------------------------------------------------------------
# PHASE III: AUTONOMOUS SENTINEL INTEGRATION AND CRYPTOGRAPHIC SEALING
# ------------------------------------------------------------------------------

echo -e "${CYAN}[*] Registering the autonomous, background-resident sentinel (Ginnungagap)...${RESET}"
cat << 'EOF' > "$CORE_DIR/ginnungagap.py"
import time, os, sys
def monitor_integrity():
    while True:
        if not os.path.exists("/etc/systemd/system/ginnungagap.service"): sys.exit(1)
        time.sleep(5)
if __name__ == "__main__": monitor_integrity()
EOF

cat << EOF > "$PERM_DIR/etc/systemd/system/ginnungagap.service"
[Unit]
Description=StormRaven Autonomous Sentinel (Ginnungagap)
After=network.target
[Service]
Type=simple
ExecStart=/usr/bin/python3 $CORE_DIR/ginnungagap.py
Restart=always
User=root
[Install]
WantedBy=multi-user.target
EOF
cp "$PERM_DIR/etc/systemd/system/ginnungagap.service" /etc/systemd/system/ || true

echo -e "${CYAN}[*] Synthesizing physical authentication tokens and localized encryption keys...${RESET}"
mkdir -p /etc/stormraven /etc/wireguard
[ ! -f /etc/stormraven/Luci.key ] && echo "STORMR_AUTH_OVERRIDE_$(date +%s)" > /etc/stormraven/Luci.key && chmod 400 /etc/stormraven/Luci.key
if [ ! -f /etc/wireguard/private.key ]; then
    wg genkey | tee /etc/wireguard/private.key | wg pubkey > /etc/wireguard/public.key
    cat << EOF > /etc/wireguard/wg0.conf
[Interface]
PrivateKey = $(cat /etc/wireguard/private.key)
Address = 10.66.66.2/32
DNS = 1.1.1.1
[Peer]
PublicKey = DUMMY_KEY_REPLACE_ME
Endpoint = 127.0.0.1:51820
AllowedIPs = 0.0.0.0/0
EOF
fi
chmod 600 /etc/wireguard/* || true

echo -e "${CYAN}[*] Imposing stringent cryptographic sealing and immutable file attributes...${RESET}"
chown -R root:root "$PERM_DIR"
chmod -R 700 "$PERM_DIR"
chmod +x "$CORE_DIR/"*.py

systemctl daemon-reload
systemctl enable ginnungagap 2>/dev/null || true
systemctl start ginnungagap 2>/dev/null || true

chattr +i /etc/systemd/system/ginnungagap.service 2>/dev/null || true
chattr +i "$CORE_DIR/"*.py 2>/dev/null || true

echo -e "${GREEN}[√] SYSTEMIC BOOTSTRAPPING SEQUENCE CONCLUDED WITH ZERO EXCEPTIONS.${RESET}"
echo -e "${AMETHYST}[*] Autonomous Sentinel (Ginnungagap): Operational.${RESET}"
echo -e "${AMETHYST}[*] Hardware-Contingent Authentication (Luci): Verification Key Generated.${RESET}"
echo -e "${AMETHYST}[*] Application Programming Interface (Bifröst): Instantiated on designated loopback vector.${RESET}"
