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

class BifrostBridge:
    @staticmethod
    def open_gateway():
        thread = threading.Thread(target=lambda: app.run(host='127.0.0.1', port=5005, debug=False, use_reloader=False), daemon=True)
        thread.start()

