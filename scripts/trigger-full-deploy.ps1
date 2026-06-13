param(
    [ValidateSet("staging", "prod", "both")]
    [string]$Environment = "both",

    [string]$Branch = "main",
    [string]$AwsRegion = "ap-south-1",
    [string]$StateBucket = "cloudmart-13-tfstate-804431973197",
    [string]$LockTable = "cloudmart-13-terraform-locks",
    [string]$OwnerEmail = "yasiram447@gmail.com",

    # Your existing staging resources are named cloudmart-staging-11-*.
    [string]$StagingTeamId = "11",
    [string]$ProdTeamId = "13",

    [switch]$NoWait
)

$ErrorActionPreference = "Stop"

function Assert-Command {
    param([string]$Name)

    if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
        throw "Required command '$Name' was not found. Install it and try again."
    }
}

function Watch-LatestRun {
    param(
        [string]$WorkflowName,
        [string]$BranchName,
        [string]$Label
    )

    if ($NoWait) {
        return
    }

    Start-Sleep -Seconds 5
    $runId = gh run list `
        --workflow $WorkflowName `
        --branch $BranchName `
        --limit 1 `
        --json databaseId `
        --jq ".[0].databaseId"

    if (-not $runId) {
        throw "Could not find a GitHub Actions run for '$WorkflowName' on branch '$BranchName'."
    }

    Write-Host "Watching $Label run $runId..."
    gh run watch $runId --exit-status
}

function Deploy-Environment {
    param(
        [string]$Name,
        [string]$TeamId
    )

    Write-Host ""
    Write-Host "=== Terraform apply: $Name (team_id=$TeamId) ==="
    gh workflow run "terraform-environment.yml" `
        --ref $Branch `
        -f environment=$Name `
        -f action=apply `
        -f aws_region=$AwsRegion `
        -f state_bucket=$StateBucket `
        -f lock_table=$LockTable `
        -f team_id=$TeamId `
        -f owner_email=$OwnerEmail

    Watch-LatestRun `
        -WorkflowName "terraform-environment.yml" `
        -BranchName $Branch `
        -Label "Terraform $Name"

    Write-Host ""
    Write-Host "=== EKS build/push/deploy: $Name ==="
    gh workflow run "eks-build-push-deploy.yml" `
        --ref $Branch `
        -f environment=$Name `
        -f deploy_to_eks=true

    Watch-LatestRun `
        -WorkflowName "eks-build-push-deploy.yml" `
        -BranchName $Branch `
        -Label "EKS deploy $Name"
}

Assert-Command "gh"

$status = gh auth status 2>&1
if ($LASTEXITCODE -ne 0) {
    throw "GitHub CLI is not authenticated. Run 'gh auth login' first."
}

if ($Environment -eq "staging" -or $Environment -eq "both") {
    Deploy-Environment -Name "staging" -TeamId $StagingTeamId
}

if ($Environment -eq "prod" -or $Environment -eq "both") {
    Deploy-Environment -Name "prod" -TeamId $ProdTeamId
}

Write-Host ""
Write-Host "Done. Check GitHub Actions for final logs and URLs."
