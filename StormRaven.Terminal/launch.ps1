<#
.SYNOPSIS
STORM RAVEN OS: TERMINAL ORCHESTRATOR (Project Leviathan)
.DESCRIPTION
Normalizes the environment to F:\StormRaven_Demigorgon and executes the 
Odin/Thor command-line interface.

.AUTHOR
Architect (Ethical Hacking Div)
#>

# ---[ CONFIGURATION: THE ABYSS ]---
$ProjectRoot  = "F:\StormRaven_Demigorgon"
$TerminalRoot = "F:\StormRaven.Terminal"
$BinaryName   = "stormraven.exe"
$BuildPath    = Join-Path $ProjectRoot "target\release\$BinaryName"

Write-Host ">>> STORM RAVEN TERMINAL: INITIALIZING <<<" -ForegroundColor Cyan

# ---[ PHASE 1: ARTIFACT VERIFICATION ]---
if (-not (Test-Path $BuildPath)) {
    Write-Warning "Artifact Not Found: $BuildPath"
    Write-Host "[*] Attempting Synthesis via Cargo..." -ForegroundColor Yellow
    
    if (Test-Path "$ProjectRoot\Cargo.toml") {
        Push-Location $ProjectRoot
        try {
            cargo build --release
            Write-Host "[+] Synthesis Successful." -ForegroundColor Green
        } catch {
            Write-Error "Cargo Build Failed. Ensure Rust toolchain is installed and ProjectRoot is valid."
            exit 1
        }
        Pop-Location
    } else {
        Write-Error "CRITICAL: Source code missing in $ProjectRoot. Cannot synthesize binary."
        exit 1
    }
}

# ---[ PHASE 2: ENVIRONMENT NORMALIZATION ]---
# Clear legacy pathing to prevent 'Experiment-626' collisions
$env:PATH = "$TerminalRoot;$ProjectRoot\target\release;" + $env:PATH

# ---[ PHASE 3: EXECUTION ]---
Write-Host "[*] Engaging Leviathan Protocol..." -ForegroundColor Magenta
& $BuildPath @args