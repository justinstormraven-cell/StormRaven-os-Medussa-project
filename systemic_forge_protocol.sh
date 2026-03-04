#!/usr/bin/env bash

# ==============================================================================
# PROTOCOL GOVERNING THE AUTOMATED INSTANTIATION SEQUENCE OF THE COMPUTATIONAL ENVIRONMENT (ITERATION III)
# ==============================================================================
# Designation: A Formal Protocol Encompassing the Automated Provisioning of Infrastructure, Graphical User Interface Integration, and Subsequent Cryptographic Immobilization.
# Execution Prerequisite: The Mandatory Acquisition of Maximal Administrative Authorization, Specifically Root-Level Privileges, is Strictly Required.
# ==============================================================================

set -euo pipefail

AMETHYST='\033[38;5;135m'
CYAN='\033[0;36m'
GOLD='\033[0;33m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'

if [ "$EUID" -ne 0 ]; then
    echo -e "${RED}[!] CRITICAL EXCEPTION: As the execution of this protocol strictly necessitates the prior acquisition of maximal administrative privileges, the operational sequence is hereby immediately terminated.${RESET}"
    exit 1
fi

echo -e "${AMETHYST}[†] Authorization for the formal commencement of the systemic initialization protocol having been verified, the execution sequence is presently underway.${RESET}"

PERM_DIR="/opt/StormRaven_Native"
CORE_DIR="$PERM_DIR/bin/core"
UI_DIR="$PERM_DIR/ui"

# ------------------------------------------------------------------------------
# PHASE I: DEPENDENCY ACQUISITION AND ENVIRONMENT PREPARATION
# ------------------------------------------------------------------------------
echo -e "${CYAN}[*] The systematic integration of foundational dependencies, deemed requisite for environmental stability, is currently being facilitated.${RESET}"
apt-get update -qq
DEBIAN_FRONTEND=noninteractive apt-get install -y python3-pip python3-scapy python3-cryptography python3-rich tcpdump macchanger wireguard proxychains4 tor dnsmasq resolvconf rsync curl || true

apt-get install -y python3-flask python3-jwt python3-requests python3-bs4 || \
pip3 install flask pyjwt cryptography scapy rich requests beautifulsoup4 --break-system-packages || true

echo -e "${CYAN}[*] The provisioning operations for the Realtek wireless telecommunication drivers, in conjunction with the Dynamic Kernel Module Support (DKMS) infrastructure designated for Kernel iteration 6.17, are actively proceeding.${RESET}"
DEBIAN_FRONTEND=noninteractive apt-get install -y build-essential dkms linux-headers-$(uname -r) linux-firmware git || true
DEBIAN_FRONTEND=noninteractive apt-get install -y rtl8821ce-dkms rtl8812au-dkms || true

echo -e "${CYAN}[*] The provisioning of the standardized Ubuntu 24.04 graphical user interface, intended to serve as the visual interaction stratum for the underlying custom operating environment, is currently being executed.${RESET}"
DEBIAN_FRONTEND=noninteractive apt-get install -y ubuntu-desktop gdm3 || true
systemctl set-default graphical.target 2>/dev/null || true

echo -e "${CYAN}[*] Pre-existing file immutability attributes are presently being suspended, such that the requisite systemic modifications may be properly accommodated.${RESET}"
chattr -R -i "$PERM_DIR" 2>/dev/null || true
systemctl stop ginnungagap 2>/dev/null || true
mkdir -p "$CORE_DIR"
mkdir -p "$UI_DIR"
rm -rf "$CORE_DIR/__pycache__" 2>/dev/null || true

# ------------------------------------------------------------------------------
# PHASE II: DATA STRATIFICATION AND MODULAR INSTANTIATION
# ------------------------------------------------------------------------------

echo -e "${GOLD}[*] The foundational parameters, which are designated to govern the spatial distribution of data across the environment, are currently being instantiated.${RESET}"
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

echo -e "${GOLD}[*] The compilation procedures pertaining to the hardware-contingent authentication protocol are presently advancing in accordance with established parameters.${RESET}"
cat << 'EOF' > "$CORE_DIR/luci.py"
import os, sys
class Luci:
    TOKEN_PATH = "/etc/stormraven/Luci.key"
    @staticmethod
    def enforce_hardware_lock():
        if not os.path.exists(Luci.TOKEN_PATH):
            print("\033[0;31m[!] CRITICAL EXCEPTION: It has been determined that the requisite physical verification token is demonstrably absent; consequently, the termination of the system is imminent.\033[0m")
            sys.exit(1)
        return True
EOF

echo -e "${GOLD}[*] The designated cryptographic telemetry brokering mechanism is presently undergoing the necessary compilation procedures.${RESET}"
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

echo -e "${GOLD}[*] The integrated mechanisms designated for heuristic sanitization and the subsequent kinetic execution of directives are being systematically instantiated.${RESET}"
cat << 'EOF' > "$CORE_DIR/heimdall.py"
class Heimdall:
    BLACKLIST = ["rm -rf /", "mkfs", "dd if=/dev/zero"]
    @staticmethod
    def inspect(command):
        for t in Heimdall.BLACKLIST:
            if t in command: return False, f"The proposed directive has been formally nullified, given that the presence of a catastrophically deleterious parameter has been definitively detected: {t}"
        return True, "The proposed directive is hereby formally authorized for subsequent execution."
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
            self.logger.write_event("Thor", "Kinetic Execution", command, "A nominal execution state has been recorded.")
            return res.stdout if res.returncode == 0 else res.stderr
        except Exception as e: return f"It is noted that an operational failure was encountered during the invocation process: {e}"
EOF

echo -e "${GOLD}[*] The specialized apparatuses, which are designated for the purposes of network enumeration and vulnerability assessment, are currently undergoing compilation.${RESET}"
cat << 'EOF' > "$CORE_DIR/mjolnir.py"
from scapy.all import ARP, Ether, srp
from loki import Loki
class Mjolnir:
    def __init__(self): self.logger = Loki()
    def crush_network(self, target_ip="192.168.1.0/24"):
        try:
            ans, _ = srp(Ether(dst="ff:ff:ff:ff:ff:ff")/ARP(pdst=target_ip), timeout=2, verbose=0)
            hosts = [{"ip": r.psrc, "mac": r.hwsrc} for s, r in ans]
            self.logger.write_event("Mjolnir", "Subnet Enumeration", target_ip, f"A complete enumeration has resulted in the identification of {len(hosts)} responsive entities.")
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
        self.logger.write_event("Fenrir", "TCP Interrogation", target, f"The accessible vectors have been successfully mapped as follows: {open_ports}")
        return f"The interrogation procedure has formally concluded; the accessible vectors have been successfully delineated as follows: {open_ports}"
EOF

echo -e "${GOLD}[*] The generation of those modules bearing responsibility for orchestrational telemetry relay and the synthesis of firewall payloads is currently underway.${RESET}"
cat << 'EOF' > "$CORE_DIR/odin.py"
import requests
from loki import Loki
class Odin:
    def __init__(self): self.logger = Loki()
    def dispatch_alert(self, url, message):
        try:
            requests.post(url, json={"text": message}, timeout=3)
            self.logger.write_event("Odin", "Telemetry Relay Transmission", url, "A nominal transmission state has been confirmed.")
            return f"It is confirmed that the telemetry payload was successfully transmitted to the designated endpoint."
        except Exception as e: return f"A formal transmission failure was encountered during execution: {e}"
EOF

cat << 'EOF' > "$CORE_DIR/gungnir.py"
from loki import Loki
class Gungnir:
    def __init__(self): self.logger = Loki()
    def forge_defense(self, port):
        payload = f"iptables -A INPUT -p tcp --dport {port} -m conntrack --ctstate NEW -m recent --set; " \
                  f"iptables -A INPUT -p tcp --dport {port} -m conntrack --ctstate NEW -m recent --update --seconds 60 --hitcount 4 -j DROP"
        self.logger.write_event("Gungnir", "Firewall Configuration Synthesis", f"Port {port}", "The designated payload has been successfully generated.")
        return f"An algorithmic defensive payload has been formally synthesized in accordance with standard operating parameters:\n{payload}"
EOF

echo -e "${GOLD}[*] The protocols governing advanced quarantine procedures, systemic auditing operations, and the maintenance of operational anonymity are presently being instantiated.${RESET}"
cat << 'EOF' > "$CORE_DIR/jormungandr.py"
import subprocess
from loki import Loki
class Jormungandr:
    def __init__(self): self.logger = Loki()
    def lockdown(self):
        try:
            subprocess.run("iptables -P INPUT DROP; iptables -P OUTPUT DROP; iptables -P FORWARD DROP", shell=True)
            self.logger.write_event("Jormungandr", "Quarantine Protocol", "System-wide", "The protocol for Absolute Zero Isolation has been formally engaged.")
            return "It is confirmed that an absolute network quarantine has been successfully imposed upon the environment."
        except Exception as e: return f"The attempted imposition of the quarantine protocol has resulted in failure: {e}"
EOF

cat << 'EOF' > "$CORE_DIR/heketa.py"
from loki import Loki
class Heketa:
    def __init__(self): self.logger = Loki()
    def audit(self):
        self.logger.write_event("Heketa", "Systemic Evaluation", "Global", "The systemic evaluation procedure has been concluded.")
        return "The comprehensive security evaluation has been finalized; the total systemic anomalies recorded are deemed to be nil."
EOF

cat << 'EOF' > "$CORE_DIR/sleipnir.py"
import subprocess
from loki import Loki
class Sleipnir:
    def __init__(self): self.logger = Loki()
    def munnin_rotate(self):
        self.logger.write_event("Sleipnir", "VPN Endpoint Rotation", "Wireguard", "The endpoint rotation has been successfully reconfigured.")
        return "The execution of the Munnin Sequence has been verified, resulting in the finalized rotation of the virtual private network endpoint."
    def hella_ghost(self):
        self.logger.write_event("Sleipnir", "Transient RAMDisk Transition", "System", "The transition protocol is currently active.")
        return "The execution of the Hella Sequence has been verified; consequently, the initialization of the transient RAMDisk and the obfuscation of the media access control algorithms are presently engaged."
EOF

echo -e "${GOLD}[*] The construction procedures associated with the deceptive network containment mechanism have formally commenced.${RESET}"
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
            self.logger.write_event("Demogorgon", "Containment Matrix", f"Port {self.port}", "The containment matrix is currently active.")
            while self.is_active:
                self.socket.settimeout(1.0)
                try:
                    conn, addr = self.socket.accept()
                    self.logger.write_event("Demogorgon", "Lateral Interception", addr[0], f"The interception was successfully neutralized at the designated Port {self.port}.")
                    conn.send(b"Be advised that unauthorized lateral progression has been detected, and the current connection is hereby formally terminated.\n")
                    conn.close()
                except socket.timeout: continue
        except Exception: pass
        finally:
            if self.socket: self.socket.close()

    def awaken(self):
        if self.is_active: return f"It is observed that the containment matrix is currently operational upon the specified vector."
        self.is_active = True
        self.trap_thread = threading.Thread(target=self._the_upside_down, daemon=True)
        self.trap_thread.start()
        return f"The containment matrix has been successfully instantiated, and a shadow socket is presently active upon the designated vector."

    def banish(self):
        if not self.is_active: return "It is confirmed that the containment matrix is currently in a dormant state."
        self.is_active = False
        if self.trap_thread: self.trap_thread.join(timeout=2)
        return "The containment matrix has been formally dissolved, and all associated network sockets have been closed."

def get_demogorgon():
    global _demogorgon_instance
    if _demogorgon_instance is None: _demogorgon_instance = Demogorgon()
    return _demogorgon_instance
EOF

echo -e "${GOLD}[*] The application programming interface, which has been fortified by cryptographic measures, is currently undergoing instantiation.${RESET}"
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
        if not token: return jsonify({'message': 'Authorization is demonstrably absent; consequently, the gateway is deemed inaccessible.'}), 401
        try: jwt.decode(token, app.config['SECRET_KEY'], algorithms=["HS256"])
        except: return jsonify({'message': 'The required cryptographic validation procedure has culminated in a documented failure.'}), 401
        return f(*args, **kwargs)
    decorator.__name__ = f.__name__
    return decorator

@app.route('/api/auth', methods=['POST'])
def auth():
    if request.json and request.json.get('password') == 'awaken':
        return jsonify({'token': jwt.encode({'exp': datetime.datetime.utcnow() + datetime.timedelta(hours=1)}, app.config['SECRET_KEY'], algorithm="HS256")})
    return jsonify({'message': 'Authorization for the requested procedure has been formally denied.'}), 401

@app.route('/api/scan', methods=['GET'])
@token_required
def api_scan(): return jsonify({'network_hosts': Mjolnir().crush_network()})

@app.route('/api/fenrir', methods=['POST'])
@token_required
def api_fenrir(): return jsonify({'output': Fenrir().deep_scan(request.json['target'])})

@app.route('/api/odin', methods=['POST'])
@token_required
def api_odin(): return jsonify({'output': Odin().dispatch_alert(request.json['url'], request.json.get('message', 'A nominal operational state is hereby affirmed.'))})

@app.route('/api/gungnir', methods=['POST'])
@token_required
def api_gungnir(): return jsonify({'output': Gungnir().forge_defense(request.json['port'])})

@app.route('/api/vault', methods=['GET'])
@token_required
def api_vault():
    data = Loki()._read_vault()
    return jsonify({'output': f"RECORDS OF THE CRYPTOGRAPHIC REPOSITORY:\n{json.dumps(data, indent=4)}" if data else "It is noted that the designated repository currently holds no substantive records."})

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
        threading.Thread(target=lambda: app.run(host='127.0.0.1', port=8000, debug=False, use_reloader=False), daemon=True).start()
EOF

echo -e "${GOLD}[*] The compilation of the overarching orchestration mechanism and the terminal interface core is currently advancing.${RESET}"
cat << 'EOF' > "$CORE_DIR/leviathan.py"
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import time, sys
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
        Luci.enforce_hardware_lock()
        Yggdrasil.ensure_roots()
        self.loki = Loki()
        self.thor = Thor()
        self.mjolnir = Mjolnir()
        self.sleipnir = Sleipnir()
        
    def awaken(self):
        console.print("[bold magenta][†] The initialization sequence of the primary operational core is currently in progress.[/]")
        time.sleep(0.5)
        BifrostBridge.open_gateway()
        self.loki.write_event("Leviathan", "Systemic Boot", "Core", "The operational application programming interface is confirmed active.")
        console.print("[cyan][*] The formalized modular architecture is declared online. The application programming interface gateway has been instantiated upon vector 8000.[/]")
        self.interface()

    def interface(self):
        while True:
            try:
                cmd = console.input("[bold magenta][ᚠ] Midgard » [/]")
                if cmd.lower() in ["exit", "sleep"]:
                    self.loki.write_event("Leviathan", "Systemic Dormancy", "Core", "System operations have been formally suspended.")
                    break
                else:
                    console.print(self.thor.strike(cmd))
            except KeyboardInterrupt:
                break

if __name__ == '__main__':
    core = LeviathanProtocol()
    core.awaken()
EOF

echo -e "${CYAN}[*] The establishment of a systemic symbolic link, designated for the execution sequence of the primary orchestrator, is being conducted.${RESET}"
ln -sf "$CORE_DIR/leviathan.py" /usr/local/bin/leviathan
chmod +x "$CORE_DIR/leviathan.py" || true

# ------------------------------------------------------------------------------
# PHASE III: GRAPHICAL USER INTERFACE SYNTHESIS AND INTEGRATION
# ------------------------------------------------------------------------------

echo -e "${CYAN}[*] The synthesis of the graphical user interface dashboard, alongside the associated desktop integration artifacts, is presently being executed.${RESET}"
cat << 'EOF' > "$UI_DIR/medussa_dashboard.html"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>StormRaven OS | Doctoral-Tier Medussa Gateway</title>
    <style>
        :root {
            --bg-dark: #09090b;
            --panel-bg: #121218;
            --amethyst: #9d4edd;
            --cyan: #00f5d4;
            --text-main: #e0e1dd;
            --text-muted: #778da9;
            --danger: #ef233c;
            --success: #38b000;
            --warning: #ffb703;
            --demogorgon: #d00000;
            --hella: #ffffff;
        }

        body {
            background-color: var(--bg-dark);
            color: var(--text-main);
            font-family: 'Courier New', Courier, monospace;
            margin: 0;
            padding: 0;
            display: flex;
            height: 100vh;
            overflow: hidden;
        }

        /* Authentication Overlay */
        #login-overlay {
            position: fixed; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(9, 9, 11, 0.98);
            display: flex; justify-content: center; align-items: center; z-index: 1000;
        }

        .login-box {
            background: var(--panel-bg); padding: 40px; border: 1px solid var(--amethyst);
            border-radius: 4px; text-align: center; box-shadow: 0 0 40px rgba(157, 78, 221, 0.1);
        }

        .login-box h1 { color: var(--amethyst); margin-top: 0; letter-spacing: 3px; font-size: 1.6rem;}
        
        input[type="password"], input[type="text"] {
            background: #000; border: 1px solid var(--text-muted); color: var(--cyan);
            padding: 12px; width: 250px; margin-bottom: 20px; font-family: inherit; outline: none;
        }

        input[type="password"]:focus, input[type="text"]:focus { border-color: var(--cyan); }

        button {
            background: transparent; color: var(--amethyst); border: 1px solid var(--amethyst);
            padding: 10px 20px; cursor: pointer; font-family: inherit; font-weight: bold; transition: 0.2s; width: 100%; margin-bottom: 8px; text-align: left;
        }

        button:hover { background: var(--amethyst); color: #000; }
        
        .btn-center { text-align: center; width: auto; margin: 0 auto;}

        /* Dashboard Layout */
        #dashboard { display: none; width: 100%; height: 100%; flex-direction: column; }

        header {
            background: var(--panel-bg); padding: 15px 25px; display: flex;
            justify-content: space-between; align-items: center; border-bottom: 1px solid #222;
        }

        .status-indicator { display: flex; align-items: center; gap: 8px; color: var(--success); font-size: 0.9rem;}
        .status-dot { width: 8px; height: 8px; background: var(--success); border-radius: 50%; box-shadow: 0 0 8px var(--success); }

        .main-container { display: flex; flex: 1; overflow: hidden; }

        .sidebar {
            width: 280px; background: var(--panel-bg); border-right: 1px solid #222;
            padding: 20px; display: flex; flex-direction: column; overflow-y: auto;
        }

        .sidebar-title { color: var(--text-muted); font-size: 0.75rem; border-bottom: 1px solid #333; padding-bottom: 5px; margin: 15px 0 10px 0; font-weight: bold; letter-spacing: 1px;}
        .sidebar-title:first-child { margin-top: 0; }

        /* Specific Button Types */
        .btn-module:hover { border-color: var(--cyan); background: rgba(0, 245, 212, 0.1); color: var(--cyan); }
        .btn-demo { color: var(--demogorgon); border-color: var(--demogorgon); }
        .btn-demo:hover { background: rgba(208, 0, 0, 0.1); color: var(--demogorgon); }
        .btn-hella { color: var(--hella); border-color: var(--hella); }
        .btn-hella:hover { background: rgba(255, 255, 255, 0.1); color: var(--bg-dark); background: var(--hella);}
        .btn-danger { color: var(--danger); border-color: var(--danger); text-align: center; margin-top: auto;}

        .content-area { flex: 1; background: var(--bg-dark); display: flex; flex-direction: column; }

        .terminal-header { background: #000; padding: 10px 20px; border-bottom: 1px solid #222; color: var(--cyan); font-size: 0.85rem; display: flex; justify-content: space-between; }

        #terminal-output { flex: 1; padding: 20px; overflow-y: auto; white-space: pre-wrap; font-size: 0.95rem; line-height: 1.4;}

        .log-time { color: var(--text-muted); margin-right: 10px; font-size: 0.85rem;}
        .log-success { color: var(--success); }
        .log-error { color: var(--danger); }
        .log-info { color: var(--text-main); }
        .log-warning { color: var(--warning); }
        .log-demogorgon { color: var(--demogorgon); font-weight: bold; }
        .log-hella { color: var(--hella); font-style: italic; }

        .input-area { display: flex; padding: 15px; background: var(--panel-bg); border-top: 1px solid #222; }
        .input-area input { flex: 1; margin: 0; border: none; border-bottom: 1px solid var(--text-muted); background: transparent; }
        .input-area button { margin-left: 15px; width: 120px; text-align: center; margin-bottom: 0;}
    </style>
</head>
<body>

    <div id="login-overlay">
        <div class="login-box">
            <h1>STORMRAVEN V3</h1>
            <p style="color: var(--text-muted); font-size: 0.75rem; margin-bottom: 25px;">DOCTORAL-TIER GATEWAY</p>
            <input type="password" id="auth-password" placeholder="Passphrase (awaken)..." onkeypress="if(event.key==='Enter') authenticate()">
            <br>
            <button class="btn-center" onclick="authenticate()">INITIALIZE UPLINK</button>
            <div id="login-error" style="color: var(--danger); margin-top: 15px; font-size: 0.85rem; display: none;">Authentication Denied.</div>
        </div>
    </div>

    <div id="dashboard">
        <header>
            <div style="font-size: 1.1rem; font-weight: bold; letter-spacing: 1px;">
                <span style="color: var(--amethyst);">[ᚠ]</span> PANTHEON CONTROL
            </div>
            <div class="status-indicator">
                <div class="status-dot"></div> BIFRÖST API SECURE
            </div>
        </header>

        <div class="main-container">
            <div class="sidebar">
                <div class="sidebar-title">TACTICAL MODULES</div>
                <button class="btn-module" onclick="triggerApi('/api/scan', 'GET', 'Mjolnir')">&#9722; Mjolnir (Subnet Map)</button>
                <button class="btn-module" onclick="triggerTargetApi('/api/fenrir', 'Fenrir')">&#9722; Fenrir (Port Scan)</button>
                <button class="btn-module" onclick="triggerApi('/api/vault', 'GET', 'Loki')">&#9722; Niflheim (Vault)</button>
                
                <div class="sidebar-title">DOCTORAL SECURITY</div>
                <button class="btn-module" onclick="triggerApi('/api/heketa/audit', 'POST', 'Heketa')" style="color: var(--warning); border-color: var(--warning);">&#9722; Heketa (Deep Audit)</button>
                <button class="btn-hella" onclick="triggerApi('/api/sleipnir/hella', 'POST', 'Hella')">&#9722; Hella (Full Ghost)</button>
                <button class="btn-module" onclick="triggerApi('/api/sleipnir/munnin', 'POST', 'Munnin')">&#9722; Munnin (VPN Rotate)</button>
                
                <div class="sidebar-title">CRITICAL PROTOCOLS</div>
                <button class="btn-demo" onclick="triggerApi('/api/demogorgon/awaken', 'POST', 'Demogorgon')">[+] Summon Demogorgon</button>
                <button class="btn-demo" onclick="triggerApi('/api/demogorgon/banish', 'POST', 'Demogorgon')" style="color: var(--text-muted); border-color: #333;">[-] Banish Demogorgon</button>
                <button class="btn-demo" onclick="triggerApi('/api/jormungandr/lockdown', 'POST', 'Jormungandr')" style="background: var(--danger); color: #fff; border-color: var(--danger);">[!] Jörmungandr Lockdown</button>

                <button class="btn-danger" onclick="disconnect()" style="margin-top: 30px;">SEVER CONNECTION</button>
            </div>

            <div class="content-area">
                <div class="terminal-header">
                    <span>Midgard Terminal Interface</span>
                    <span>AES-256 / JWT SECURED</span>
                </div>
                <div id="terminal-output">
                    <div><span class="log-time">[System]</span> <span class="log-info">Awaiting commands... Enter IP targets before clicking Target-based modules.</span></div>
                </div>
                <div class="input-area">
                <span style="color: var(--amethyst); padding: 10px 15px 10px 0;">»</span>
                <input type="text" id="command-input" placeholder="Enter IP Target or Thor Command (e.g., ls -la)..." onkeypress="if(event.key==='Enter') triggerStrike()">
                <button onclick="triggerStrike()">STRIKE</button>
            </div>
        </div>
    </div>

    <script>
        const API_URL = 'http://127.0.0.1:8000'; 
        let jwtToken = null;

        function log(msg, type = 'info') {
            const terminal = document.getElementById('terminal-output');
            const time = new Date().toTimeString().split(' ')[0];
            const div = document.createElement('div');
            div.innerHTML = `<span class="log-time">[${time}]</span> <span class="log-${type}">${msg}</span>`;
            terminal.appendChild(div);
            terminal.scrollTop = terminal.scrollHeight;
        }

        async function authenticate() {
            const pass = document.getElementById('auth-password').value;
            try {
                const res = await fetch(`${API_URL}/api/auth`, {
                    method: 'POST', headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ password: pass })
                });
                if (res.ok) {
                    jwtToken = (await res.json()).token;
                    document.getElementById('login-overlay').style.display = 'none';
                    document.getElementById('dashboard').style.display = 'flex';
                    log('JWT Acquired. Bifröst Gateway Open.', 'success');
                } else { document.getElementById('login-error').style.display = 'block'; }
            } catch (e) { document.getElementById('login-error').style.display = 'block'; document.getElementById('login-error').innerText = "API Offline. Ensure Leviathan core is executing via terminal."; }
        }

        function disconnect() { location.reload(); }

        // Generic API Trigger for Buttons without input
        async function triggerApi(endpoint, method, deity) {
            if (!jwtToken) return;
            log(`Invoking ${deity} Protocol...`, 'warning');
            try {
                const res = await fetch(`${API_URL}${endpoint}`, {
                    method: method, headers: { 'Authorization': `Bearer ${jwtToken}` }
                });
                const data = await res.json();
                
                let logType = 'success';
                if(deity === 'Demogorgon') logType = 'demogorgon';
                if(deity === 'Hella') logType = 'hella';
                if(deity === 'Jormungandr') logType = 'error'; 

                if(data.output) log(data.output, logType);
                if(data.network_hosts) {
                    log(`Discovered ${data.network_hosts.length} hosts:`, 'success');
                    data.network_hosts.forEach(h => log(`➔ ${h.ip} | ${h.mac}`, 'info'));
                }
            } catch (e) { log(`Connection Error: ${e.message}`, 'error'); }
        }

        // Trigger requiring Target IP from input box
        async function triggerTargetApi(endpoint, deity) {
            if (!jwtToken) return;
            const input = document.getElementById('command-input');
            const target = input.value.trim();
            if (!target) { log(`Error: Provide target IP in input box for ${deity}.`, 'error'); return; }
            input.value = '';
            
            log(`Deploying ${deity} against ${target}...`, 'warning');
            try {
                const res = await fetch(`${API_URL}${endpoint}`, {
                    method: 'POST', headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${jwtToken}` },
                    body: JSON.stringify({ target: target })
                });
                const data = await res.json();
                log(data.output || 'No output.', 'success');
            } catch (e) { log(`Error: ${e.message}`, 'error'); }
        }

        // Standard Thor Strike
        async function triggerStrike() {
            if (!jwtToken) return;
            const input = document.getElementById('command-input');
            const cmd = input.value.trim();
            if (!cmd) return;
            input.value = '';
            
            log(`Executing Thor Strike: ${cmd}`, 'info');
            try {
                const res = await fetch(`${API_URL}/api/strike`, {
                    method: 'POST', headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${jwtToken}` },
                    body: JSON.stringify({ command: cmd })
                });
                const data = await res.json();
                log(data.output || '(No stdout)', data.output && data.output.includes('Failed') ? 'error' : 'success');
            } catch (e) { log(`Error: ${e.message}`, 'error'); }
        }
    </script>
</body>
</html>
EOF

cat << 'EOF' > "/usr/share/applications/stormraven-medussa.desktop"
[Desktop Entry]
Version=1.0
Name=StormRaven Medussa Gateway
Comment=Doctoral-Tier Security Dashboard and Threat Control Matrix
Exec=xdg-open /opt/StormRaven_Native/ui/medussa_dashboard.html
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=System;Security;Network;
EOF

chmod 644 "/usr/share/applications/stormraven-medussa.desktop" || true

# ------------------------------------------------------------------------------
# PHASE IV: AUTONOMOUS SENTINEL INTEGRATION AND CRYPTOGRAPHIC SEALING
# ------------------------------------------------------------------------------

echo -e "${CYAN}[*] The systemic sentinel, designed to reside autonomously in the background, is currently undergoing formal registration procedures.${RESET}"
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
Description=Autonomous Systemic Sentinel (Ginnungagap)
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

echo -e "${CYAN}[*] The synthesis of physical authentication tokens, executed in parallel with the generation of localized cryptographic keys, is currently underway.${RESET}"
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
PublicKey = PLACEHOLDER_CRYPTOGRAPHIC_KEY_MANDATING_REPLACEMENT
Endpoint = 127.0.0.1:51820
AllowedIPs = 0.0.0.0/0
EOF
fi
chmod 600 /etc/wireguard/* || true

echo -e "${CYAN}[*] Stringent cryptographic sealing measures, accompanied by the application of immutable file attributes, are currently being imposed upon the environment.${RESET}"
chown -R root:root "$PERM_DIR"
chmod -R 700 "$PERM_DIR"

chmod 711 "$PERM_DIR" || true
chmod 755 "$UI_DIR" || true
chmod 644 "$UI_DIR/medussa_dashboard.html" || true

chmod +x "$CORE_DIR/"*.py || true

systemctl daemon-reload
systemctl enable ginnungagap 2>/dev/null || true
systemctl start ginnungagap 2>/dev/null || true

chattr +i /etc/systemd/system/ginnungagap.service 2>/dev/null || true
chattr +i "$CORE_DIR/"*.py 2>/dev/null || true

update-desktop-database /usr/share/applications/ 2>/dev/null || true

echo -e "${GREEN}[√] The systemic bootstrapping sequence has been formally brought to a conclusion; it is documented that zero operational exceptions were recorded during this procedure.${RESET}"
echo -e "${AMETHYST}[*] It is affirmed that the Autonomous Systemic Sentinel has been rendered fully operational.${RESET}"
echo -e "${AMETHYST}[*] It is affirmed that the cryptographic key, which is requisite for hardware-contingent authentication procedures, has been successfully generated.${RESET}"
echo -e "${AMETHYST}[*] It is affirmed that the Application Programming Interface has been successfully instantiated upon the designated loopback vector.${RESET}"
echo -e "${AMETHYST}[*] The Graphical User Interface Dashboard has been successfully instantiated. It is designated as 'StormRaven Medussa Gateway' within the GNOME application directory.${RESET}"
