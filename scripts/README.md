# Ghost Platform - Self-Hosted Runner Implementation

## 🚀 Quick Start Guide

### Prerequisites
- Windows 10/11 or Linux/WSL2
- Docker Desktop installed and running
- Administrator/sudo access
- GitHub account with repository access

### Step 1: Setup GitHub Secrets

1. **Create GitHub Personal Access Token**:
   - Go to: https://github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Permissions: `repo`, `admin:org`, `workflow`
   - Copy the token

2. **Add Secrets to Repository**:
   ```bash
   # Install GitHub CLI if not present
   winget install GitHub.cli
   
   # Login to GitHub
   gh auth login
   
   # Add secrets
   gh secret set RUNNER_TOKEN --body "your-github-token"
   gh secret set DOCKERHUB_USERNAME --body "your-docker-username"
   gh secret set DOCKERHUB_TOKEN --body "your-docker-token"
   ```

### Step 2: Install Self-Hosted Runner

#### For Windows:
```powershell
# Navigate to scripts directory
cd d:\devops_projects\ghost_on_prem\scripts

# Run setup script
.\setup-runner.ps1 -GitHubToken "your-github-token"
```

#### For Linux/WSL:
```bash
# Navigate to scripts directory
cd /mnt/d/devops_projects/ghost_on_prem/scripts

# Make script executable
chmod +x setup-runner.sh

# Run setup script
./setup-runner.sh "your-github-token"
```

### Step 3: Verify Runner Registration

1. **Check GitHub UI**:
   - Go to: https://github.com/dmitri166/ghost_on_prem_project/settings/actions/runners
   - Verify your runner appears as "Idle" (green)

2. **Check runner status**:
   ```bash
   # Windows
   Get-Service "actions.runner.*"

   # Linux
   sudo systemctl status actions-runner.*
   ```

### Step 4: Test the Pipeline

1. **Make a small change** to any file in:
   - `infrastructure/terraform/`
   - `applications/ghost-app/`
   - `platform/`

2. **Commit and push**:
   ```bash
   git add .
   git commit -m "Test self-hosted runner deployment"
   git push origin master
   ```

3. **Monitor deployment**:
   - Go to: https://github.com/dmitri166/ghost_on_prem_project/actions
   - Watch the workflow run in real-time

### Step 5: Verify k3d Cluster

After successful deployment:

```bash
# Check cluster status
kubectl get nodes

# Check all resources
kubectl get all -A

# Check ArgoCD
kubectl get pods -n argocd
```

## 📊 Monitoring Your Deployment

### GitHub Actions UI
- **Main Dashboard**: https://github.com/dmitri166/ghost_on_prem_project/actions
- **Runner Status**: https://github.com/dmitri166/ghost_on_prem_project/settings/actions/runners
- **Workflow Logs**: Click on any workflow run to see detailed logs

### Local Monitoring
```bash
# Check Docker containers
docker ps

# Check k3d clusters
k3d cluster list

# Check runner logs
tail -f /var/log/actions-runner.log
```

## 🔧 Troubleshooting

### Common Issues

1. **Runner not showing in GitHub**:
   - Check token has correct permissions
   - Verify network connectivity
   - Check runner logs for errors

2. **Terraform fails**:
   - Verify Docker Desktop is running
   - Check k3d installation
   - Review workflow logs

3. **Permission denied**:
   - Run setup script as Administrator/sudo
   - Check Docker daemon permissions
   - Verify GitHub token scopes

### Debug Commands

```bash
# Test Docker access
docker run hello-world

# Test k3d
k3d version

# Test Terraform
terraform --version

# Check runner connectivity
curl -H "Authorization: token $GITHUB_TOKEN" https://api.github.com/user
```

## 🎯 Success Indicators

✅ **Runner Setup Complete**:
- Runner appears in GitHub UI as "Idle"
- Runner service is running locally
- All prerequisites installed (Docker, k3d, Terraform, kubectl)

✅ **Pipeline Working**:
- Workflow runs on self-hosted runner
- k3d cluster created successfully
- ArgoCD and MetalLB installed
- Applications deployed via GitOps

✅ **Monitoring Active**:
- Real-time logs in GitHub Actions UI
- Local cluster accessible via kubectl
- ArgoCD dashboard accessible

## 📚 Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [k3d Documentation](https://k3d.io/)
- [ArgoCD Documentation](https://argoproj.github.io/argo-cd/)
- [Terraform Documentation](https://www.terraform.io/docs)

## 🆘 Support

If you encounter issues:

1. **Check logs** in GitHub Actions UI
2. **Review runner logs** locally
3. **Verify prerequisites** are installed
4. **Check network connectivity**
5. **Validate GitHub token** permissions

For additional help, create an issue in the repository with:
- Error messages
- System information
- Steps to reproduce
- Logs (sanitized)
