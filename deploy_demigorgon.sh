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
● stormraven.service - StormRaven Native Kernel Orchestrator (Leviathan Variant)
     Loaded: loaded (/etc/systemd/system/stormraven.service; enabled; preset: enabled)
     Active: active (running) since Mon 2026-03-02 15:44:40 CST; 26ms ago
   Main PID: 71340 (python3)
      Tasks: 1 (limit: 4111)
     Memory: 3.4M (peak: 3.4M)
        CPU: 21ms
     CGroup: /system.slice/stormraven.service
             └─71340 /usr/bin/python3 /opt/StormRaven_Native/bin/core/leviathan.py

Mar 02 15:44:40 luci-HP-Laptop-15-fd0xxx systemd[1]: Started stormraven.service - StormRaven Native Kernel Orchestrator (Leviathan Variant).
