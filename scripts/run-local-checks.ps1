# =============================================================
# CloudMart Local CI Checks
# Mirrors: .github/workflows/services-ci.yml
#
# Usage:
#   Run service checks only:
#     powershell -ExecutionPolicy Bypass -File .\scripts\run-local-checks.ps1
#
#   Run all local CI checks:
#     powershell -ExecutionPolicy Bypass -File .\scripts\run-local-checks.ps1 -Service all -IncludeDocker -IncludeKubernetes
#
#   Run one service:
#     powershell -ExecutionPolicy Bypass -File .\scripts\run-local-checks.ps1 -Service notification-service
#
#   Valid -Service values:
#     notification-service | order-service | product-service | user-service | frontend | all
# =============================================================

param(
    [ValidateSet("notification-service", "order-service", "product-service", "user-service", "frontend", "all")]
    [string]$Service = "all",

    [switch]$IncludeDocker,
    [switch]$IncludeTrivy,
    [switch]$IncludeKubernetes
)

$Root = Split-Path -Parent $PSScriptRoot
$ServicesDir = Join-Path $Root "services"
$HasError = $false

$DockerServices = @(
    @{ Name = "product-service"; Context = "services/product-service"; BuildArgs = "" },
    @{ Name = "order-service"; Context = "services/order-service"; BuildArgs = "" },
    @{ Name = "user-service"; Context = "services/user-service"; BuildArgs = "" },
    @{ Name = "notification-service"; Context = "services/notification-service"; BuildArgs = "" },
    @{ Name = "frontend"; Context = "services/frontend"; BuildArgs = "--build-arg NGINX_CONF=nginx.conf" }
)

function Write-Header([string]$Text) {
    Write-Host ""
    Write-Host "--------------------------------------------------" -ForegroundColor Cyan
    Write-Host "  $Text" -ForegroundColor Cyan
    Write-Host "--------------------------------------------------" -ForegroundColor Cyan
}

function Write-Step([string]$Text) {
    Write-Host "  >> $Text" -ForegroundColor Yellow
}

function Write-Pass([string]$Text) {
    Write-Host "  [PASS] $Text" -ForegroundColor Green
}

function Write-Fail([string]$Text) {
    Write-Host "  [FAIL] $Text" -ForegroundColor Red
    $script:HasError = $true
}

function Test-CommandExists([string]$Name) {
    return $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Run-Cmd([string]$Command, [string]$Label) {
    Write-Step $Label
    try {
        Invoke-Expression $Command
    }
    catch {
        Write-Fail "$Label FAILED ($($_.Exception.Message))"
        return $false
    }

    if ($LASTEXITCODE -ne 0) {
        Write-Fail "$Label FAILED (exit code $LASTEXITCODE)"
        return $false
    }
    Write-Pass "$Label passed"
    return $true
}

function Check-NodeService([string]$Name) {
    Write-Header "Node Service: $Name"
    Push-Location (Join-Path $ServicesDir $Name)
    try {
        [void](Run-Cmd "npm install --silent" "Install dependencies")
        [void](Run-Cmd "npm run lint" "ESLint lint")
        [void](Run-Cmd "npm test -- --passWithNoTests" "Jest unit tests")
    }
    finally {
        Pop-Location
    }
}

function Check-PythonService([string]$Name) {
    Write-Header "Python Service: $Name"
    Push-Location (Join-Path $ServicesDir $Name)
    try {
        [void](Run-Cmd "python -m pip install -r requirements.txt -q" "Install dependencies")
        [void](Run-Cmd "python -m py_compile app.py" "Python compile check")
        [void](Run-Cmd "python -m flake8 app.py" "flake8 lint")
        [void](Run-Cmd "python -m pytest" "pytest unit tests")
    }
    finally {
        Pop-Location
    }
}

function Check-Frontend {
    Write-Header "Frontend (React)"
    Push-Location (Join-Path $ServicesDir "frontend")
    try {
        [void](Run-Cmd "npm install --silent" "Install dependencies")
        [void](Run-Cmd "npm run lint" "ESLint lint")
        [void](Run-Cmd "npm test" "React unit tests")
        [void](Run-Cmd "npm run build" "React production build")
    }
    finally {
        Pop-Location
    }
}

function Check-DockerImages {
    Write-Header "Docker Build"
    if (-not (Test-CommandExists "docker")) {
        Write-Fail "docker is not installed or not on PATH"
        return
    }

    Push-Location $Root
    try {
        foreach ($Item in $DockerServices) {
            $Image = "cloudmart/$($Item.Name):local"
            $BuildArgs = $Item.BuildArgs
            if ([string]::IsNullOrWhiteSpace($BuildArgs)) {
                [void](Run-Cmd "docker build -t $Image $($Item.Context)" "Build $Image")
            }
            else {
                [void](Run-Cmd "docker build $BuildArgs -t $Image $($Item.Context)" "Build $Image")
            }
        }
    }
    finally {
        Pop-Location
    }
}

function Check-TrivyImages {
    Write-Header "Trivy CRITICAL Vulnerability Scan"
    if (-not (Test-CommandExists "trivy")) {
        Write-Fail "trivy is not installed or not on PATH"
        return
    }

    foreach ($Item in $DockerServices) {
        $Image = "cloudmart/$($Item.Name):local"
        [void](Run-Cmd "trivy image --severity CRITICAL --exit-code 1 --ignore-unfixed $Image" "Scan $Image")
    }
}

function Check-KubernetesManifests {
    Write-Header "Kubernetes Manifest Validation"
    if (-not (Test-CommandExists "kubectl")) {
        Write-Fail "kubectl is not installed or not on PATH"
        return
    }
    if (-not (Test-CommandExists "kubeconform")) {
        Write-Fail "kubeconform is not installed or not on PATH"
        return
    }

    Push-Location $Root
    try {
        [void](Run-Cmd "kubectl kustomize k8s/base > rendered.yaml" "Render Kubernetes manifests")
        [void](Run-Cmd "kubeconform -strict -summary rendered.yaml" "Validate Kubernetes manifests")
    }
    finally {
        Pop-Location
    }
}

Write-Host ""
Write-Host "==================================================" -ForegroundColor Magenta
Write-Host "        CloudMart Local CI Checks                 " -ForegroundColor Magenta
Write-Host "==================================================" -ForegroundColor Magenta

switch ($Service) {
    "notification-service" { Check-NodeService "notification-service" }
    "order-service" { Check-NodeService "order-service" }
    "product-service" { Check-PythonService "product-service" }
    "user-service" { Check-PythonService "user-service" }
    "frontend" { Check-Frontend }
    "all" {
        Check-NodeService "notification-service"
        Check-NodeService "order-service"
        Check-PythonService "product-service"
        Check-PythonService "user-service"
        Check-Frontend
    }
}

if ($IncludeDocker -or $IncludeTrivy) {
    Check-DockerImages
}

if ($IncludeTrivy) {
    Check-TrivyImages
}

if ($IncludeKubernetes) {
    Check-KubernetesManifests
}

Write-Host ""
Write-Host "--------------------------------------------------" -ForegroundColor Cyan

if ($HasError) {
    Write-Host "  RESULT: FAILED - Some checks did not pass. See output above." -ForegroundColor Red
    exit 1
}

Write-Host "  RESULT: ALL CHECKS PASSED" -ForegroundColor Green
exit 0
