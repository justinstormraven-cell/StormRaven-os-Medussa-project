#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import os
import sys
from cryptography.fernet import Fernet

def breach_vault():
    print("\033[38;5;135m[†] INITIATING NIFLHEIM VAULT DECRYPTION...\033[0m")
    
    key_path = "/opt/StormRaven_Native/var/vault/loki_master.key"
    log_path = "/opt/StormRaven_Native/var/logs/shadow/shadow_telemetry.enc"
    
    # 1. Verify Assets
    if not os.path.exists(key_path):
        print("\033[0;31m[!] Error: Master Key missing. Vault is permanently sealed.\033[0m")
        sys.exit(1)
        
    if not os.path.exists(log_path):
        print("\033[0;33m[*] Vault is empty. No telemetry recorded yet.\033[0m")
        sys.exit(0)

    try:
        # 2. Extract Key & Initialize Cipher
        with open(key_path, "rb") as kf:
            master_key = kf.read()
            
        cipher = Fernet(master_key)
        
        # 3. Read & Decrypt Ciphertext
        with open(log_path, "rb") as lf:
            encrypted_data = lf.read()
            
        decrypted_bytes = cipher.decrypt(encrypted_data)
        telemetry_log = json.loads(decrypted_bytes.decode('utf-8'))
        
        # 4. Display the Shadow Record
        print("\033[0;32m[√] VAULT BREACHED. DISPLAYING SHADOW TELEMETRY:\033[0m\n")
        
        # Print with nice JSON formatting and syntax highlighting colors
        formatted_json = json.dumps(telemetry_log, indent=4)
        
        # Simple colorization for terminal
        formatted_json = formatted_json.replace('"', '\033[0;36m"\033[0m')
        print(formatted_json)
        
        print(f"\n\033[38;5;135m[*] Total Events Logged: {len(telemetry_log)}\033[0m")

    except Exception as e:
        print(f"\033[0;31m[!] Cryptographic Failure. Decryption rejected: {str(e)}\033[0m")

if __name__ == "__main__":
    if os.geteuid() != 0:
        print("\033[0;31m[!] Root privileges required to access the vault. Use sudo.\033[0m")
        sys.exit(1)
    breach_vault()
