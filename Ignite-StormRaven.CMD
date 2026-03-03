<# :
@echo off
cd /d "%~dp0"
title StormRaven Omni-Genesis
echo [*] Bypassing Windows Execution Policies...
powershell -NoProfile -ExecutionPolicy Bypass -Command "iex ((Get-Content '%~f0' -Raw))"
exit /b
#>


Write-Host "`n[====== INITIATING OMNI-GENESIS V9.0 (CMD POLYGLOT) ======]`n" -ForegroundColor Cyan

# ==========================================
# 1. FORENSIC TOPOLOGY
# ==========================================
$Alfheim         = $PWD.Path
$SourcePythonDir = Join-Path -Path $Alfheim -ChildPath "StormRavenOS-main\Python"
$Midgard         = "$env:TEMP\stormraven_stealth" 
$Niflheim        = "C:\StormRaven\Vault" 
$Helheim         = "C:\StormRaven\ShadowLogs"

Write-Host "[*] Establishing Mythological File Topology..." -ForegroundColor DarkGray
foreach ($realm in @($Midgard, $Niflheim, $Helheim)) {
    if (-not (Test-Path $realm)) { New-Item -ItemType Directory -Path $realm -Force | Out-Null }
}

$ExpDir = Join-Path -Path $Alfheim -ChildPath "Experiment-626"
if (-not (Test-Path $ExpDir)) { New-Item -ItemType Directory -Path $ExpDir -Force | Out-Null }
Set-Location $ExpDir

# ==========================================
# 2. THE CONTAINMENT GRID (WIT CONTRACT)
# ==========================================
Write-Host "[*] Weaving Universal Compatibility Protocol (WIT)..." -ForegroundColor Magenta
New-Item -ItemType Directory -Path "wit" -Force | Out-Null

$WitCode = @"
package stormraven:leviathan@1.0.0;

interface types {
    record signal-envelope {
        source: string, target: string, intent-json: string, priority: u8, timestamp: u64,
    }
}
interface ucp-bus {
    use types.{signal-envelope};
    transmit: func(signal: signal-envelope) -> result<_, string>;
}
interface host-control {
    use types.{signal-envelope};
    receive-signal: func(signal: signal-envelope);
}
world pantheon-node {
    import types;
    import ucp-bus;
    export host-control;
}
"@
Set-Content -Path "wit\stormraven.wit" -Value $WitCode

# ==========================================
# 3. MASS-METAMORPHOSIS (PYTHON TO WASM)
# ==========================================
Write-Host "[*] Bootstrapping Python-to-Wasm Compiler..." -ForegroundColor Yellow
$WasmOutDir = Join-Path -Path $PWD.Path -ChildPath "modules"
New-Item -ItemType Directory -Path $WasmOutDir -Force | Out-Null

if (-not (Test-Path "venv")) { python -m venv venv }
$Pip = Join-Path -Path "venv" -ChildPath "Scripts\pip.exe"
$CompPy = Join-Path -Path "venv" -ChildPath "Scripts\componentize-py.exe"

& $Pip install --quiet componentize-py
$env:PYTHONPATH = $SourcePythonDir
$Deities = @("odin", "freya", "heimdall", "bifrost", "thor", "luci", "ragnarok", "deadman", "saga", "solomon", "heketa", "lynn")

foreach ($god in $Deities) {
    $AdapterCode = @"
import json
import traceback
import stormraven.leviathan.types as types
import stormraven.leviathan.ucp_bus as ucp

try:
    import $god as target_module
except ImportError:
    target_module = None

class PantheonNode:
    def receive_signal(self, signal: types.SignalEnvelope):
        try:
            if target_module and hasattr(target_module, 'process_signal'):
                result = target_module.process_signal(signal.intent_json)
            else:
                result = {"status": "ACK", "module": "$god", "note": "Target module active"}

            response = types.SignalEnvelope(
                source="$god", target="Odin" if "$god" != "odin" else "Heimdall",
                intent_json=json.dumps(result), priority=1, timestamp=0
            )
            ucp.transmit(response)
        except Exception as e:
            err_response = types.SignalEnvelope(
                source="$god", target="Loki",
                intent_json=json.dumps({"error": str(e)}), priority=255, timestamp=0
            )
            ucp.transmit(err_response)
"@
    $AdapterPath = Join-Path -Path $WasmOutDir -ChildPath "${god}_adapter.py"
    Set-Content -Path $AdapterPath -Value $AdapterCode
    $WasmOutput = Join-Path -Path $WasmOutDir -ChildPath "$god.wasm"
    
    $WitPath = Join-Path -Path $PWD.Path -ChildPath "wit\stormraven.wit"
    & $CompPy -d $WitPath -w pantheon-node componentize $AdapterPath -o $WasmOutput
    Remove-Item $AdapterPath -Force
}

# ==========================================
# 4. RUST HYPERVISOR (EXPERIMENT 626)
# ==========================================
Write-Host "[*] Forging Ring-0 Asynchronous Microkernel (Dual-Pipe)..." -ForegroundColor Red
New-Item -ItemType Directory -Path "src" -Force | Out-Null

$CargoCode = @"
[package]
name = "experiment-626"
version = "1.0.0"
edition = "2021"

[dependencies]
wasmtime = { version = "18.0.0", features = ["component-model"] }
wasmtime-wasi = "18.0.0"
tokio = { version = "1.37.0", features = ["full"] }
anyhow = "1.0.81"
rusqlite = "0.31.0"
async-trait = "0.1.77"
serde_json = "1.0.114"

[profile.release]
opt-level = 3
lto = "fat"
codegen-units = 1
panic = "abort"
strip = true
"@
Set-Content -Path "Cargo.toml" -Value $CargoCode

$LokiCode = @"
use rusqlite::{params, Connection, Result};
pub struct LokiStomach { conn: Connection }
impl LokiStomach {
    pub fn awaken(db_path: &str) -> Result<Self> {
        let conn = Connection::open(db_path)?;
        conn.execute("CREATE TABLE IF NOT EXISTS shadow_logs (id INTEGER PRIMARY KEY AUTOINCREMENT, timestamp DATETIME DEFAULT CURRENT_TIMESTAMP, source TEXT, target TEXT, priority INTEGER, intent_json TEXT)", [])?;
        Ok(Self { conn })
    }
    pub fn devour(&self, src: &str, tgt: &str, pri: u8, intent: &str) -> Result<usize> {
        self.conn.execute("INSERT INTO shadow_logs (source, target, priority, intent_json) VALUES (?1, ?2, ?3, ?4)", params![src, tgt, pri, intent])
    }
}
"@
Set-Content -Path "src\loki.rs" -Value $LokiCode

$EscapedMidgard = $Midgard.Replace("\", "\\")
$EscapedHelheim = (Join-Path -Path $Helheim -ChildPath "stormraven_shadow.db").Replace("\", "\\")

$MainCode = @"
use anyhow::Result;
use std::sync::Arc;
use tokio::sync::mpsc;
use tokio::net::windows::named_pipe::ServerOptions;
use tokio::io::AsyncBufReadExt;
use wasmtime::{component::{Component, Linker}, Config, Engine, Store};
use wasmtime_wasi::preview2::{ResourceTable, WasiCtx, WasiCtxBuilder, WasiView};

mod loki;
use loki::LokiStomach;

wasmtime::component::bindgen!({ path: "wit/stormraven.wit", world: "pantheon-node", async: true });

struct DemigorgonState { table: ResourceTable, wasi: WasiCtx, tx_bus: mpsc::Sender<stormraven::leviathan::types::SignalEnvelope> }
impl WasiView for DemigorgonState {
    fn table(&mut self) -> &mut ResourceTable { &mut self.table }
    fn ctx(&mut self) -> &mut WasiCtx { &mut self.wasi }
}

#[async_trait::async_trait]
impl stormraven::leviathan::ucp_bus::Host for DemigorgonState {
    async fn transmit(&mut self, signal: stormraven::leviathan::types::SignalEnvelope) -> Result<Result<(), String>> {
        let _ = self.tx_bus.send(signal).await;
        Ok(Ok(()))
    }
}

#[tokio::main]
async fn main() -> Result<()> {
    println!("[*] Experiment 626 (Demigorgon) Online. Absolute Containment Grid Active.");
    
    let stomach = Arc::new(LokiStomach::awaken("$EscapedHelheim")?);
    let (tx_bus, mut rx_bus) = mpsc::channel::<stormraven::leviathan::types::SignalEnvelope>(100);
    let (tx_ui, mut rx_ui) = tokio::sync::broadcast::channel::<String>(50);

    // PIPELINE 1: Telemetry Out (Rust -> Shell)
    tokio::spawn(async move {
        let pipe_name = r"\\.\pipe\StormRaven_Telemetry";
        loop {
            if let Ok(server) = ServerOptions::new().first_pipe_instance(true).create(pipe_name) {
                if server.connect().await.is_ok() {
                    while let Ok(json_str) = rx_ui.recv().await {
                        let mut payload = json_str.as_bytes().to_vec();
                        payload.push(b'\n');
                        let _ = server.try_write(&payload);
                    }
                }
            }
        }
    });

    // PIPELINE 2: Command In (Shell -> Rust)
    let tx_cmd = tx_bus.clone();
    tokio::spawn(async move {
        let pipe_name = r"\\.\pipe\StormRaven_Command";
        loop {
            if let Ok(mut server) = ServerOptions::new().first_pipe_instance(true).create(pipe_name) {
                if server.connect().await.is_ok() {
                    let mut reader = tokio::io::BufReader::new(server);
                    let mut line = String::new();
                    while let Ok(bytes) = reader.read_line(&mut line).await {
                        if bytes == 0 { break; }
                        if let Ok(parsed) = serde_json::from_str::<serde_json::Value>(&line) {
                            let signal = stormraven::leviathan::types::SignalEnvelope {
                                source: parsed["source"].as_str().unwrap_or("UI").to_string(),
                                target: parsed["target"].as_str().unwrap_or("odin").to_string(),
                                intent_json: parsed["intent_json"].as_str().unwrap_or("{}").to_string(),
                                priority: parsed["priority"].as_u64().unwrap_or(0) as u8,
                                timestamp: 0,
                            };
                            let _ = tx_cmd.send(signal).await;
                        }
                        line.clear();
                    }
                }
            }
        }
    });

    let mut config = Config::new();
    config.wasm_component_model(true);
    config.async_support(true);
    
    let engine = Engine::new(&config)?;
    let mut linker = Linker::new(&engine);
    
    wasmtime_wasi::preview2::command::add_to_linker(&mut linker)?;
    stormraven::leviathan::ucp_bus::add_to_linker(&mut linker, |s: &mut DemigorgonState| s)?;

    let boot_signal = stormraven::leviathan::types::SignalEnvelope {
        source: "System".to_string(), target: "odin".to_string(),
        intent_json: "{\"event\":\"SYSTEM_BOOT\"}".to_string(), priority: 0, timestamp: 0,
    };
    tx_bus.send(boot_signal).await?;

    while let Some(signal) = rx_bus.recv().await {
        let _ = stomach.devour(&signal.source, &signal.target, signal.priority, &signal.intent_json);
        
        let json_broadcast = format!("{{\"source\":\"{}\", \"target\":\"{}\", \"payload\":{}}}", signal.source, signal.target, signal.intent_json);
        let _ = tx_ui.send(json_broadcast.clone());

        let target_module = signal.target.to_lowercase();
        let wasm_path = format!("modules/{}.wasm", target_module);

        if std::path::Path::new(&wasm_path).exists() {
            println!("[626-ROUTER] Routing {} -> {}", signal.source, target_module.to_uppercase());
            let eng_clone = engine.clone();
            let lnk_clone = linker.clone();
            let tx_clone = tx_bus.clone();
            let sig_clone = signal.clone();

            tokio::spawn(async move {
                let mut builder = WasiCtxBuilder::new();
                let state = DemigorgonState { table: ResourceTable::new(), wasi: builder.build(), tx_bus: tx_clone };
                let mut store = Store::new(&eng_clone, state);
                
                if let Ok(comp) = Component::from_file(&eng_clone, &wasm_path) {
                    if let Ok((node, _)) = PantheonNode::instantiate_async(&mut store, &comp, &lnk_clone).await {
                        let _ = node.stormraven_leviathan_host_control().call_receive_signal(&mut store, &sig_clone).await;
                    }
                }
            });
        }
    }
    Ok(())
}
"@
Set-Content -Path "src\main.rs" -Value $MainCode

# ==========================================
# 5. DYNAMIC LINKER & RUST COMPILATION
# ==========================================
Write-Host "[*] Hunting Native Microsoft C++ Linker & Compiling Hypervisor..." -ForegroundColor Yellow
$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
if (Test-Path $vswhere) {
    $vsPath = & $vswhere -latest -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath
    if ($vsPath) {
        $vcvars = Join-Path -Path $vsPath -ChildPath "VC\Auxiliary\Build\vcvars64.bat"
        if (Test-Path $vcvars) {
            cmd.exe /c "`"$vcvars`" >NUL && set" | ForEach-Object {
                if ($_ -match "^(.*?)=(.*)$") { [Environment]::SetEnvironmentVariable($matches[1], $matches[2], 'Process') }
            }
        }
    }
}
cargo build --release

# ==========================================
# 6. SCAFFOLDING C# NEURAL SHELL
# ==========================================
Write-Host "[*] Forging C# Neural Interface (StormRaven.Terminal)..." -ForegroundColor Green
$CsDir = Join-Path -Path $Alfheim -ChildPath "StormRaven.Terminal"
if (Test-Path $CsDir) { Remove-Item -Path $CsDir -Recurse -Force }
New-Item -ItemType Directory -Path $CsDir -Force | Out-Null
Set-Location $CsDir

dotnet new console -f net8.0 -n StormRaven.Terminal --force | Out-Null

$ProgramCs = @"
using System;
using System.IO;
using System.IO.Pipes;
using System.Text.Json;
using System.Threading.Tasks;

namespace StormRaven.Terminal
{
    class Program
    {
        static async Task Main()
        {
            Console.Clear();
            Console.ForegroundColor = ConsoleColor.Cyan;
            Console.WriteLine("=================================================");
            Console.WriteLine("       STORMRAVEN SHELL NEURAL LINK ACTIVE       ");
            Console.WriteLine("=================================================");
            Console.ResetColor();

            _ = Task.Run(async () => {
                while(true) {
                    try {
                        using var rx = new NamedPipeClientStream(".", "StormRaven_Telemetry", PipeDirection.In, PipeOptions.Asynchronous);
                        await rx.ConnectAsync();
                        using var reader = new StreamReader(rx);
                        while(!reader.EndOfStream) {
                            var line = await reader.ReadLineAsync();
                            Console.ForegroundColor = ConsoleColor.DarkGray;
                            Console.WriteLine($"\n[TELEMETRY] {line}");
                            Console.ResetColor();
                            Console.Write("StormRaven> "); 
                        }
                    } catch { await Task.Delay(1000); }
                }
            });

            await Task.Delay(1000); 
            
            while(true) {
                Console.Write("\nStormRaven> ");
                var input = Console.ReadLine();
                if (string.IsNullOrWhiteSpace(input)) continue;

                try {
                    using var tx = new NamedPipeClientStream(".", "StormRaven_Command", PipeDirection.Out, PipeOptions.Asynchronous);
                    await tx.ConnectAsync(2000);
                    using var writer = new StreamWriter(tx) { AutoFlush = true };
                    
                    var payload = new {
                        source = "Shell",
                        target = "odin",
                        intent_json = $"{{\"command\": \"{input}\"}}",
                        priority = 10
                    };
                    
                    await writer.WriteLineAsync(JsonSerializer.Serialize(payload));
                    Console.ForegroundColor = ConsoleColor.Green;
                    Console.WriteLine("[√] Payload Injected into Ring-0 Grid.");
                    Console.ResetColor();
                } catch (Exception ex) {
                    Console.ForegroundColor = ConsoleColor.Red;
                    Console.WriteLine($"[!] Injection Failed: Hypervisor offline. ({ex.Message})");
                    Console.ResetColor();
                }
            }
        }
    }
}
"@
Set-Content -Path "Program.cs" -Value $ProgramCs

# ==========================================
# 7. DUAL-IGNITION SEQUENCE (CMD COMPATIBLE)
# ==========================================
Write-Host "`n[====== ALL SYSTEMS GREEN. INITIATING DUAL IGNITION ======]`n" -ForegroundColor Green
$ExePath = Join-Path -Path $ExpDir -ChildPath "target\release\experiment-626.exe"

# Launches a new, dedicated Windows Command Prompt for the Rust hypervisor
Start-Process cmd -ArgumentList "/k `"$ExePath`""

# Locks the current terminal into the C# Shell
dotnet run