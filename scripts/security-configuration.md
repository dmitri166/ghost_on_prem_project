# Security Configuration for Public Repository with Self-Hosted Runners

## 🚨 Security Risks of Public Repos with Self-Hosted Runners

When your repository is public, anyone can:
1. Fork your repository
2. Modify workflows to run malicious code
3. Execute arbitrary commands on your local machine
4. Access your Docker daemon, k3d clusters, and local files

## 🛡️ Security Solutions

### **Option 1: Repository-Level Protection (Recommended)**

#### 1. Make Repository Private
```bash
# Convert to private repository
gh repo edit dmitri166/ghost_on_prem_project --visibility private
```

#### 2. Use Branch Protection Rules
```yaml
# In GitHub UI: Settings → Branches → Add rule
- Require pull request reviews before merging
- Require status checks to pass before merging
- Require branches to be up to date before merging
- Include administrators
```

#### 3. Environment Protection
```yaml
# In .github/workflows/ci-cd.yml
terraform-apply:
  runs-on: self-hosted
  environment: production  # Requires approval
  permissions:
    contents: read
    actions: read
```

### **Option 2: Runner-Level Security**

#### 1. Use Runner Groups with Restrictions
```bash
# Create restricted runner group
gh api --method POST \
  -H "Accept: application/vnd.github.v3+json" \
  /orgs/dmitri166/actions/runner-groups \
  --data '{
    "name": "restricted-runners",
    "visibility": "selected",
    "runners": [],
    "restricted_to_workflows": true
  }'
```

#### 2. Workflow-Level Restrictions
```yaml
# In runner configuration
./config.sh \
  --url "$REPO_URL" \
  --token "$RUNNER_TOKEN" \
  --name "$RUNNER_NAME" \
  --runnergroup "restricted-runners" \
  --work "./_work" \
  --unattended \
  --labels "self-hosted,linux,x64,infrastructure"
```

#### 3. Use Docker Container Isolation
```yaml
# In workflow, run jobs in containers
jobs:
  terraform-apply:
    runs-on: self-hosted
    container:
      image: hashicorp/terraform:latest
      options: --user root
    steps:
      - name: Apply Infrastructure
        run: |
          cd infrastructure/terraform
          terraform apply -auto-approve
```

### **Option 3: Network-Level Security**

#### 1. Firewall Rules
```bash
# Block external access to runner
sudo ufw deny from any to any port 22
sudo ufw allow from 192.168.1.0/24 to any port 22
sudo ufw enable
```

#### 2. VPN-Only Access
```bash
# Require VPN for runner access
# Configure runner to only accept connections from VPN range
```

### **Option 4: Approval-Based Security**

#### 1. Manual Approval for Dangerous Operations
```yaml
# In .github/workflows/ci-cd.yml
terraform-apply:
  runs-on: self-hosted
  environment: 
    name: production
    url: http://localhost:8080
  environment:
    name: infrastructure
    # Requires manual approval in GitHub UI
```

#### 2. Time-Based Restrictions
```yaml
# Only run during business hours
- name: Check Time
  run: |
    HOUR=$(date +%H)
    if [ $HOUR -lt 9 ] || [ $HOUR -gt 17 ]; then
      echo "❌ Infrastructure changes only allowed 9AM-5PM"
      exit 1
    fi
```

## 🎯 **Recommended Security Setup**

### **Step 1: Make Repository Private**
```bash
gh repo edit dmitri166/ghost_on_prem_project --visibility private
```

### **Step 2: Configure Branch Protection**
```bash
gh api --method PUT \
  -H "Accept: application/vnd.github.v3+json" \
  /repos/dmitri166/ghost_on_prem_project/branches/master/protection \
  --data '{
    "required_status_checks": {
      "strict": true,
      "contexts": ["policy-validation", "terraform-plan"]
    },
    "enforce_admins": true,
    "required_pull_request_reviews": {
      "required_approving_review_count": 1
    },
    "restrictions": null
  }'
```

### **Step 3: Environment Protection**
```yaml
# Create protected environments
environments:
  production:
    protected: true
    wait_timer: 300  # 5 minutes
    reviewers: ["dmitri166"]
```

### **Step 4: Runner Security**
```bash
# Configure runner with security restrictions
./config.sh \
  --url "$REPO_URL" \
  --token "$RUNNER_TOKEN" \
  --name "$RUNNER_NAME" \
  --runnergroup "infrastructure-only" \
  --work "./_work" \
  --unattended \
  --user "$(whoami)" \
  --labels "self-hosted,secure"
```

## 🔍 **Monitoring and Auditing**

### **1. Runner Activity Monitoring**
```bash
# Monitor runner logs
tail -f /home/dmitri/github-runners/_diag/Runner_*.log

# Check for suspicious activity
grep -i "error\|warning\|failed" /home/dmitri/github-runners/_diag/*.log
```

### **2. GitHub Audit Log**
```bash
# Check audit log for suspicious activity
gh api /organizations/dmitri166/audit-log
```

### **3. Network Monitoring**
```bash
# Monitor network connections
sudo netstat -tulpn | grep :22
sudo ss -tulpn | grep LISTEN
```

## 🚨 **Emergency Procedures**

### **1. Disable Runner Immediately**
```bash
# Stop runner service
sudo systemctl stop actions.runner.*

# Remove runner from GitHub
gh api --method DELETE \
  /repos/dmitri166/ghost_on_prem_project/actions/runners/$RUNNER_ID
```

### **2. Revoke All Tokens**
```bash
# Revoke GitHub tokens
gh auth logout
gh auth revoke-all

# Regenerate all secrets
gh secret set RUNNER_TOKEN --body "new-token"
```

### **3. Network Isolation**
```bash
# Disconnect from network
sudo ufw deny incoming
sudo ufw deny outgoing
```

## ✅ **Security Checklist**

- [ ] Repository is private
- [ ] Branch protection rules enabled
- [ ] Environment protection configured
- [ ] Runner groups restricted
- [ ] Docker container isolation enabled
- [ ] Network firewall rules configured
- [ ] Monitoring and logging enabled
- [ ] Emergency procedures documented
- [ ] Regular security reviews scheduled
- [ ] Team training completed

## 🎯 **Best Practices**

1. **Principle of Least Privilege**: Only grant necessary permissions
2. **Defense in Depth**: Multiple layers of security
3. **Regular Audits**: Review access logs and permissions
4. **Team Training**: Ensure team understands security risks
5. **Incident Response**: Have emergency procedures ready

## 🔄 **Alternative: Use GitHub-Hosted Runners for Public Repo**

If keeping the repo public:
```yaml
# Use GitHub-hosted runners for public operations
jobs:
  policy-validation:
    runs-on: ubuntu-latest  # Safe in cloud
  
  terraform-apply:
    runs-on: self-hosted    # Only for trusted maintainers
    if: github.actor == 'dmitri166'  # Only you can run
```

This way, anyone can contribute code, but only you can deploy infrastructure changes.
