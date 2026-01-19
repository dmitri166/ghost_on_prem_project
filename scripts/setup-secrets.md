# GitHub Secrets Configuration for Ghost Platform

## Required Secrets

### 1. GitHub Personal Access Token (for runner registration)
- **Name**: `RUNNER_TOKEN`
- **Description**: Personal access token for registering self-hosted runner
- **Permissions**: `repo`, `admin:org`, `workflow`
- **How to create**:
  1. Go to GitHub Settings → Developer settings → Personal access tokens
  2. Generate new token (classic)
  3. Select required permissions
  4. Copy token value

### 2. Terraform Cloud Token (optional)
- **Name**: `TF_API_TOKEN`
- **Description**: Terraform Cloud API token for state management
- **How to create**:
  1. Go to Terraform Cloud Settings → Tokens
  2. Create API token
  3. Copy token value

### 3. Docker Hub Credentials
- **Name**: `DOCKERHUB_USERNAME`
- **Description**: Docker Hub username for container registry
- **Value**: Your Docker Hub username

- **Name**: `DOCKERHUB_TOKEN`
- **Description**: Docker Hub access token for pushing images
- **How to create**:
  1. Go to Docker Hub Settings → Security
  2. Create new access token
  3. Copy token value

### 4. Kubeconfig Path (optional)
- **Name**: `KUBECONFIG_PATH`
- **Description**: Path to kubeconfig file on runner
- **Value**: `infrastructure/terraform/kubeconfig.yaml`

## Setup Instructions

### Adding Secrets to GitHub Repository

1. **Navigate to repository settings**:
   ```
   https://github.com/dmitri166/ghost_on_prem_project/settings/secrets/actions
   ```

2. **Add each secret**:
   - Click "New repository secret"
   - Enter name and value
   - Click "Add secret"

### Environment Protection

For production deployments, configure environment protection:

1. **Go to**: Settings → Environments
2. **Create environment**: `production`
3. **Add protection rules**:
   - Required reviewers: 1
   - Wait timer: 5 minutes
   - Prevent self-review: ✅

## Quick Setup Script

```bash
# Add secrets using GitHub CLI
gh secret set RUNNER_TOKEN --body "your-github-token"
gh secret set TF_API_TOKEN --body "your-terraform-token"
gh secret set DOCKERHUB_USERNAME --body "your-docker-username"
gh secret set DOCKERHUB_TOKEN --body "your-docker-token"
```

## Security Notes

- ✅ **Never commit secrets to repository**
- ✅ **Use least privilege principle**
- ✅ **Rotate tokens regularly**
- ✅ **Monitor secret usage**
- ✅ **Use environment-specific secrets**

## Verification

After setting up secrets:

1. **Test runner registration**:
   ```bash
   ./scripts/setup-runner.sh $RUNNER_TOKEN
   ```

2. **Verify in GitHub UI**:
   - Go to Settings → Actions → Runners
   - Check runner appears as "Idle"

3. **Test workflow**:
   - Push a small change to master
   - Monitor workflow execution in Actions tab
