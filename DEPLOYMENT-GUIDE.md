# Deploying KaChow Microservices to GitHub

This guide explains how to deploy each microservice as a separate repository to GitHub under the KaChow-Organisation organization.

## Prerequisites

1. Git installed on your system
2. GitHub account with access to KaChow-Organisation
3. GitHub CLI (`gh`) installed (optional but recommended)

## Option 1: Automated Deployment Script

### Step 1: Create GitHub Repositories

Run this PowerShell script to create all repositories:

```powershell
# deploy-to-github.ps1

$services = @(
    "shared-contracts",
    "auth-service", 
    "user-service",
    "order-service",
    "payment-service",
    "notification-service",
    "api-gateway",
    "analytics-service"
)

$org = "KaChow-Organisation"

foreach ($service in $services) {
    Write-Host "Creating repository: $org/$service" -ForegroundColor Green
    
    # Create repo using GitHub CLI
    gh repo create "$org/$service" --public --description "Microservice: $service for KaChow platform" --confirm
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Created $service" -ForegroundColor Green
    } else {
        Write-Host "✗ Failed to create $service (may already exist)" -ForegroundColor Red
    }
}

Write-Host "`nAll repositories created!" -ForegroundColor Green
```

Run it:
```powershell
# Login first
gh auth login

# Run the script
.\deploy-to-github.ps1
```

### Step 2: Push Each Service

Run this PowerShell script to push all services:

```powershell
# push-all-services.ps1

$basePath = "c:\Documents\kachow_4"
$org = "KaChow-Organisation"

$services = @(
    "shared-contracts",
    "auth-service", 
    "user-service",
    "order-service",
    "payment-service",
    "notification-service",
    "api-gateway",
    "analytics-service"
)

foreach ($service in $services) {
    $servicePath = Join-Path $basePath $service
    
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host "Processing: $service" -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
    
    if (-not (Test-Path $servicePath)) {
        Write-Host "Directory not found: $servicePath" -ForegroundColor Red
        continue
    }
    
    Set-Location $servicePath
    
    # Initialize git if not already done
    if (-not (Test-Path ".git")) {
        Write-Host "Initializing git repository..." -ForegroundColor Yellow
        git init
        git add .
        git commit -m "Initial commit: $service microservice"
    } else {
        Write-Host "Git repository already initialized" -ForegroundColor Green
    }
    
    # Add remote if not exists
    $remoteUrl = "https://github.com/$org/$service.git"
    $existingRemote = git remote get-url origin 2>$null
    
    if ($LASTEXITCODE -ne 0) {
        Write-Host "Adding remote origin..." -ForegroundColor Yellow
        git remote add origin $remoteUrl
    } else {
        Write-Host "Remote already exists: $existingRemote" -ForegroundColor Green
    }
    
    # Push to GitHub
    Write-Host "Pushing to GitHub..." -ForegroundColor Yellow
    git push -u origin main 2>$null
    
    if ($LASTEXITCODE -ne 0) {
        # Try master branch
        git push -u origin master 2>$null
    }
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "✓ Successfully pushed $service" -ForegroundColor Green
        Write-Host "  URL: https://github.com/$org/$service" -ForegroundColor Gray
    } else {
        Write-Host "✗ Failed to push $service" -ForegroundColor Red
    }
}

Set-Location $basePath
Write-Host "`n========================================" -ForegroundColor Green
Write-Host "Deployment Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Green
```

## Option 2: Manual Deployment

If you prefer to do it manually for each service:

### For Each Service:

```bash
# Navigate to service directory
cd c:\Documents\kachow_4\auth-service

# Initialize git repository
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: auth-service microservice"

# Add remote (replace with your GitHub org)
git remote add origin https://github.com/KaChow-Organisation/auth-service.git

# Push
git push -u origin main
```

## Option 3: Using GitHub Web Interface

1. Go to https://github.com/KaChow-Organisation
2. Click "New repository"
3. Create repository with same name as service (e.g., `auth-service`)
4. In your local directory:

```bash
cd auth-service
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/KaChow-Organisation/auth-service.git
git push -u origin main
```

## Post-Deployment Setup

### 1. Add Repository Topics/Tags

Go to each GitHub repo → Settings → Topics and add:
- `microservices`
- `nodejs`
- `express`
- `kachow`

### 2. Enable Features

In each repo, enable:
- Issues (for bug tracking)
- Discussions (for questions)
- Wiki (for documentation)

### 3. Add Branch Protection (Optional)

For production repos, add branch protection rules to `main`:
- Require pull request reviews
- Require status checks
- Prevent force pushes

### 4. Update README Badges

Add these badges to each service README:

```markdown
![Node.js](https://img.shields.io/badge/Node.js-18+-green)
![Express](https://img.shields.io/badge/Express-4.x-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)
```

## Repository Structure on GitHub

After deployment, your GitHub org should look like:

```
KaChow-Organisation/
├── shared-contracts/
├── auth-service/
├── user-service/
├── order-service/
├── payment-service/
├── notification-service/
├── api-gateway/
└── analytics-service/
```

## Quick Reference

### Clone All Repositories

```powershell
$services = @("shared-contracts", "auth-service", "user-service", "order-service", "payment-service", "notification-service", "api-gateway", "analytics-service")
$org = "KaChow-Organisation"

foreach ($service in $services) {
    git clone "https://github.com/$org/$service.git"
}
```

### Update All Repositories

```powershell
$services = @("shared-contracts", "auth-service", "user-service", "order-service", "payment-service", "notification-service", "api-gateway", "analytics-service")

foreach ($service in $services) {
    Set-Location $service
    git pull origin main
    Set-Location ..
}
```

## Next Steps After Deployment

1. **Set up CI/CD**: Add GitHub Actions for testing and deployment
2. **Add Docker**: Containerize each service
3. **Documentation**: Enable GitHub Pages for API documentation
4. **Monitoring**: Set up health checks and monitoring dashboards
5. **Security**: Add dependabot alerts and security scanning
