## AWS App Runner Deployment

### 1. IAM Permissions Setup

Your AWS IAM user needs the following permissions:

**Option A: Using AWS Managed Policies (Easiest)**
- `AmazonEC2ContainerRegistryFullAccess` - for ECR (push/pull Docker images)
- `AWSAppRunnerFullAccess` - for App Runner service management

**Option B: Minimum Custom Policy (More Secure)**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:CreateRepository",
        "ecr:PutImage",
        "ecr:InitiateLayerUpload",
        "ecr:UploadLayerPart",
        "ecr:CompleteLayerUpload",
        "ecr:BatchCheckLayerAvailability",
        "ecr:DeleteRepository"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "apprunner:CreateService",
        "apprunner:DescribeService",
        "apprunner:DeleteService",
        "apprunner:ListServices"
      ],
      "Resource": "*"
    }
  ]
}
```

To add permissions in AWS Console:
1. Go to **IAM** → **Users** → Select your user
2. Click **Add permissions** → **Attach policies directly**
3. Search and select `AmazonEC2ContainerRegistryFullAccess` and `AWSAppRunnerFullAccess`
4. Click **Next** → **Add permissions**

### 2. Prerequisites

```bash
# Install AWS CLI (macOS)
brew install awscli

# Configure AWS credentials
aws configure
# Enter your:
# - AWS Access Key ID (get from IAM → Users → Security credentials)
# - AWS Secret Access Key
# - Default region: us-east-1
# - Default output format: json

# Ensure Docker Desktop is running
docker --version
```

### 3. Deploy Steps

#### Step 1: Create ECR Repository and Push Image

```bash
# Create ECR repository
aws ecr create-repository --repository-name nasa-calc --region us-east-1

# Output will show URI like: 123456789012.dkr.ecr.us-east-1.amazonaws.com/nasa-calc
# Copy YOUR_ACCOUNT number from this URI!

# Login to ECR (replace YOUR_ACCOUNT with your AWS account ID)
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com

# Generate and save SECRET_KEY_BASE (you'll need this for App Runner!)
mix phx.gen.secret
# Copy the output!

# Build Docker image
docker build -t nasa-calc .

# Tag image (replace YOUR_ACCOUNT)
docker tag nasa-calc:latest YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/nasa-calc:latest

# Push to ECR
docker push YOUR_ACCOUNT.dkr.ecr.us-east-1.amazonaws.com/nasa-calc:latest
```

#### Step 2: Create App Runner Service via AWS Console

1. Open [AWS App Runner Console](https://console.aws.amazon.com/apprunner)
2. Ensure region is **us-east-1** (top right)
3. Click **Create service**

**Configure Source:**
4. **Repository type**: Container registry
5. **Provider**: Amazon ECR
6. **Container image URI**: Click **Browse** → select `nasa-calc` → select `latest` tag
7. **Deployment settings**: Automatic (or Manual for testing)
8. **ECR access role**: Create new service role (auto-selected)
9. Click **Next**

**Configure Service:**
10. **Service name**: `nasa-calc`
11. **Virtual CPU & memory**: 1 vCPU & 2 GB (minimum recommended)
12. **Environment variables** → Click **Add environment variable**:
    - **Key**: `SECRET_KEY_BASE`
    - **Value**: paste the output from `mix phx.gen.secret` above
13. **Port**: `4000`
14. **Health check**: 
    - Protocol: HTTP
    - Path: `/` (default)
    - Interval: 10
    - Timeout: 5
    - Healthy threshold: 1
    - Unhealthy threshold: 5
15. Click **Next**

**Review and Create:**
16. Review all settings
17. Click **Create & deploy**
18. Wait ~5-10 minutes for deployment to complete

**Access Your App:**
19. Once status shows **Running**, copy the **Default domain** URL
20. Open the URL in your browser (e.g., `https://xxxxx.us-east-1.awsapprunner.com`)

### 4. Cleanup

```bash
# Delete App Runner service (via AWS Console or CLI)
# Console: App Runner → Select service → Actions → Delete

# Delete ECR repository
aws ecr delete-repository \
  --repository-name nasa-calc \
  --region us-east-1 \
  --force
```