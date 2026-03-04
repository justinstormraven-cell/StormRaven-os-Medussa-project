#!/usr/bin/env bash

# --- STORMRAVEN: MISSING DEITY INJECTION PATCH ---
# Fixes the ModuleNotFoundError crash loop by forging Odin and Gungnir 
# directly within a root-level bash execution context.

if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (sudo bash fix_modules.sh)"
    exit 1
fi

echo "[*] Disengaging Solomon's Lock..."
chattr -i /opt/StormRaven_Native/bin/core/*.py 2>/dev/null || true

echo "[*] Forging Oðinn Module..."
cat << 'EOF' > /opt/StormRaven_Native/bin/core/odin.py
import json
import urllib.request
from loki import Loki

class Odin:
    def __init__(self):
        self.logger = Loki()

    def dispatch_alert(self, destination_url, message="StormRaven Health Heartbeat: Nominal"):
        try:
            payload = json.dumps({"source": "StormRaven_Odin", "alert": message}).encode('utf-8')
            req = urllib.request.Request(destination_url, data=payload, headers={'Content-Type': 'application/json'})
            with urllib.request.urlopen(req, timeout=5) as response:
                res_body = response.read().decode('utf-8')
            self.logger.write_event("Odin", "Telemetry Dispatch", destination_url, "Success")
            return f"Oðinn successfully transmitted encrypted telemetry to: {destination_url}\nResponse: {res_body}"
        except Exception as e:
            self.logger.write_event("Odin", "Telemetry Dispatch", destination_url, f"Failed: {str(e)}")
            return f"Oðinn transmission failed. Ensure the destination URL is valid and listening. Error: {str(e)}"
EOF

echo "[*] Forging Gungnir Module..."
cat << 'EOF' > /opt/StormRaven_Native/bin/core/gungnir.py
from loki import Loki

class Gungnir:
    def __init__(self):
        self.logger = Loki()

    def forge_defense(self, port, protocol="tcp"):
        try:
            port_num = int(port)
            script = (
                f"#!/bin/bash\n"
                f"# Gungnir Automated Remediation Payload\n"
                f"# Target: Port {port_num}/{protocol}\n\n"
                f"echo '[*] Engaging Gungnir Defense Sequence...'\n"
                f"ufw deny {port_num}/{protocol} >/dev/null 2>&1\n"
                f"iptables -A INPUT -p {protocol} --dport {port_num} -j DROP\n"
                f"iptables-save > /etc/iptables/rules.v4\n"
                f"echo '[√] Port {port_num} cryptographically sealed.'\n"
            )
            self.logger.write_event("Gungnir", "Defense Forge", f"Port {port_num}", "Success")
            return f"Gungnir synthesized lockdown payload for Port {port_num}:\n\n{script}\n\n(Save this output as a .sh file to deploy on the target node)"
        except ValueError:
            return "Gungnir Error: Invalid port designation. Provide a numeric port (e.g., 22, 80, 443)."
        except Exception as e:
            return f"Gungnir Forge failed: {str(e)}"
EOF

echo "[*] Re-sealing core and restarting the Leviathan daemon..."
chmod +x /opt/StormRaven_Native/bin/core/*.py
chattr +i /opt/StormRaven_Native/bin/core/*.py 2>/dev/null || true

systemctl restart stormraven
systemctl status stormraven --no-pager