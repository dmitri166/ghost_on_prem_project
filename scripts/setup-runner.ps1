#!/usr/bin/env pwsh
# Ghost Platform - Self-Hosted GitHub Runner Setup Script
# This script sets up a self-hosted GitHub Actions runner on Windows

param(
    [Parameter(Mandatory=$true)]
    [string]$GitHubToken,
    
    [Parameter(Mandatory=$false)]
    [string]$RunnerName = "ghost-runner",
    
    [Parameter(Mandatory=$false)]
    [string]$RunnerGroup = "default",
    
    [Parameter(Mandatory=$false)]
    [string]$WorkDirectory = "C:\github-runners"
)

Write-Host "🚀 Setting up Ghost Platform GitHub Runner..." -ForegroundColor Green

# Create working directory
if (!(Test-Path $WorkDirectory)) {
    New-Item -ItemType Directory -Path $WorkDirectory -Force
    Write-Host "✅ Created directory: $WorkDirectory" -ForegroundColor Green
}

Set-Location $WorkDirectory

# Download latest runner
Write-Host "📥 Downloading GitHub Actions Runner..." -ForegroundColor Yellow
$RunnerVersion = "2.311.0"
$RunnerUrl = "https://github.com/actions/runner/releases/download/v$RunnerVersion/actions-runner-win-x64-$RunnerVersion.zip"
$RunnerZip = "actions-runner.zip"

Invoke-WebRequest -Uri $RunnerUrl -OutFile $RunnerZip
Expand-Archive -Path $RunnerZip -DestinationPath . -Force
Remove-Item $RunnerZip

Write-Host "✅ Runner downloaded and extracted" -ForegroundColor Green

# Configure runner
Write-Host "⚙️ Configuring runner..." -ForegroundColor Yellow
$RepoUrl = "https://github.com/dmitri166/ghost_on_prem_project"

& .\config.cmd --url $RepoUrl --token $GitHubToken --name $RunnerName --runnergroup $RunnerGroup --work .\_work

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Runner configured successfully" -ForegroundColor Green
} else {
    Write-Host "❌ Failed to configure runner" -ForegroundColor Red
    exit 1
}

# Install runner as Windows service (optional)
Write-Host "🔧 Installing runner as Windows service..." -ForegroundColor Yellow
& .\svc.sh install

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Runner service installed" -ForegroundColor Green
    Write-Host "🚀 Starting runner service..." -ForegroundColor Yellow
    & .\svc.sh start
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✅ Runner service started successfully" -ForegroundColor Green
    } else {
        Write-Host "❌ Failed to start runner service" -ForegroundColor Red
    }
} else {
    Write-Host "⚠️ Could not install as service, you can run manually" -ForegroundColor Yellow
    Write-Host "💡 Run: .\run.cmd to start the runner" -ForegroundColor Cyan
}

# Verify prerequisites
Write-Host "🔍 Verifying prerequisites..." -ForegroundColor Yellow

# Check Docker
try {
    $DockerVersion = docker --version
    Write-Host "✅ Docker: $DockerVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker not found. Please install Docker Desktop" -ForegroundColor Red
}

# Check k3d
try {
    $K3dVersion = k3d --version
    Write-Host "✅ k3d: $K3dVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ k3d not found. Installing k3d..." -ForegroundColor Yellow
    winget install k3d
}

# Check Terraform
try {
    $TerraformVersion = terraform --version
    Write-Host "✅ Terraform: $TerraformVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Terraform not found. Installing Terraform..." -ForegroundColor Yellow
    winget install Hashicorp.Terraform
}

# Check kubectl
try {
    $KubectlVersion = kubectl version --client --short
    Write-Host "✅ kubectl: $KubectlVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ kubectl not found. Installing kubectl..." -ForegroundColor Yellow
    winget install Kubernetes.kubectl
}

Write-Host "🎉 GitHub Runner setup completed!" -ForegroundColor Green
Write-Host "📍 Runner location: $WorkDirectory" -ForegroundColor Cyan
Write-Host "🌐 GitHub UI: https://github.com/dmitri166/ghost_on_prem_project/settings/actions/runners" -ForegroundColor Cyan
Write-Host "📋 Next steps:" -ForegroundColor Yellow
Write-Host "   1. Check runner status in GitHub UI" -ForegroundColor White
Write-Host "   2. Update CI/CD workflow to use self-hosted runner" -ForegroundColor White
Write-Host "   3. Test with a commit to master branch" -ForegroundColor White
