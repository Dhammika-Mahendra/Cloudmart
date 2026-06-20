# =============================================================
# CloudMart Local CI Checks
# Mirrors: .github/workflows/services-ci.yml
#
# Usage:
#   Run ALL services:
#     powershell -ExecutionPolicy Bypass -File .\scripts\run-local-checks.ps1
#
#   Run ONE service:
#     powershell -ExecutionPolicy Bypass -File .\scripts\run-local-checks.ps1 -Service notification-service
#
#   Valid -Service values:
#     notification-service | order-service | product-service | user-service | frontend | all
# =============================================================

param(
    [string]$Service = "all"
)

$Root        = Split-Path -Parent $PSScriptRoot
$ServicesDir = Join-Path $Root "services"
$HasError    = $false

# ---------- Helpers --------------------------------------------------

function Write-Header([string]$text) {
    Write-Host ""
    Write-Host "--------------------------------------------------" -ForegroundColor Cyan
    Write-Host "  $text" -ForegroundColor Cyan
    Write-Host "--------------------------------------------------" -ForegroundColor Cyan
}

function Write-Step([string]$text) {
    Write-Host "  >> $text" -ForegroundColor Yellow
}

function Write-Pass([string]$text) {
    Write-Host "  [PASS] $text" -ForegroundColor Green
}

function Write-Fail([string]$text) {
    Write-Host "  [FAIL] $text" -ForegroundColor Red
    $script:HasError = $true
}

function Run-Cmd([string]$cmd, [string]$label) {
    Write-Step $label
    Invoke-Expression $cmd
    if ($LASTEXITCODE -ne 0) {
        Write-Fail "$label FAILED (exit code $LASTEXITCODE)"
        return $false
    }
    Write-Pass "$label passed"
    return $true
}

# ---------- Node.js Service ------------------------------------------

function Check-NodeService([string]$name) {
    Write-Header "Node Service: $name"
    $dir = Join-Path $ServicesDir $name
    Push-Location $dir

    Run-Cmd "npm install --silent 2>&1 | Out-Null" "Install dependencies"
    Run-Cmd "npm run lint" "ESLint lint"
    Run-Cmd "npm test -- --passWithNoTests" "Jest unit tests"

    Pop-Location
}

# ---------- Python Service -------------------------------------------

function Check-PythonService([string]$name) {
    Write-Header "Python Service: $name"
    $dir = Join-Path $ServicesDir $name
    Push-Location $dir

    Run-Cmd "pip install -r requirements.txt -q" "Install dependencies"
    Run-Cmd "python -m py_compile app.py" "Python compile check"
    Run-Cmd "flake8 app.py" "flake8 lint"
    Run-Cmd "pytest" "pytest unit tests"

    Pop-Location
}

# ---------- Frontend -------------------------------------------------

function Check-Frontend {
    Write-Header "Frontend (React)"
    $dir = Join-Path $ServicesDir "frontend"
    Push-Location $dir

    Run-Cmd "npm install --silent 2>&1 | Out-Null" "Install dependencies"
    Run-Cmd "npm run lint" "ESLint lint"
    Run-Cmd "npm test" "React unit tests"

    Pop-Location
}

# ---------- Main -----------------------------------------------------

Write-Host ""
Write-Host "==================================================" -ForegroundColor Magenta
Write-Host "        CloudMart Local CI Checks                 " -ForegroundColor Magenta
Write-Host "==================================================" -ForegroundColor Magenta

switch ($Service) {
    "notification-service" { Check-NodeService "notification-service" }
    "order-service"        { Check-NodeService "order-service" }
    "product-service"      { Check-PythonService "product-service" }
    "user-service"         { Check-PythonService "user-service" }
    "frontend"             { Check-Frontend }
    "all" {
        Check-NodeService "notification-service"
        Check-NodeService "order-service"
        Check-PythonService "product-service"
        Check-PythonService "user-service"
        Check-Frontend
    }
    default {
        Write-Host "Unknown service: $Service" -ForegroundColor Red
        Write-Host "Valid: notification-service | order-service | product-service | user-service | frontend | all"
        exit 1
    }
}

# ---------- Summary --------------------------------------------------

Write-Host ""
Write-Host "--------------------------------------------------" -ForegroundColor Cyan

if ($HasError) {
    Write-Host "  RESULT: FAILED - Some checks did not pass. See output above." -ForegroundColor Red
    exit 1
} else {
    Write-Host "  RESULT: ALL CHECKS PASSED" -ForegroundColor Green
    exit 0
}
