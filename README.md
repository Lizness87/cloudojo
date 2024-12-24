# SAM Stack Deployment with GitHub Actions

This guide outlines how to deploy a SAM stack to multiple environments (dev, prod) using GitHub Actions.

---

## 🛠️ Prerequisites

- **AWS account** with IAM permissions for CloudFormation, S3, Lambda, etc.
- **GitHub repository** with the SAM project.
- **GitHub Actions** enabled.
- **AWS CLI** (optional, for local testing).

---

## ⚙️ Steps to Set Up Deployment

### 1. **Create IAM User and Access Keys**

1. Create an IAM user in the **AWS Management Console** with the following permissions:
   - `AdministratorAccess` or appropriate permissions for CloudFormation, S3, Lambda, etc.
2. **Save the Access Key ID** and **Secret Access Key**. These will be used in GitHub Secrets.

### 2. **Store AWS Credentials in GitHub Secrets**

1. Navigate to your GitHub repo: **Settings > Secrets > Actions**.
2. Add the following secrets:
   - `AWS_ACCESS_KEY_ID`: Your IAM user's Access Key ID.
   - `AWS_SECRET_ACCESS_KEY`: Your IAM user's Secret Access Key.
   - `AWS_REGION`: The region for deployment (e.g., `us-east-1`).

### 3. **Edit `samconfig.toml`**

Modify the `samconfig.toml` to specify the region, account, and S3 bucket for each environment (dev/prod):

```toml
[default.deploy.parameters]
stack_name = "sam-cloudojo"
resolve_s3 = true
s3_prefix = "sam-cloudojo"
region = "us-east-1"
confirm_changeset = true
capabilities = "CAPABILITY_IAM"
parameter_overrides = "AWSRegion=\"us-east-1\" AWSAccount=\"267551332587\" S3Bucket=\"sam-cloudojo\""

### 4. **Configure GitHub Actions Workflow**
The GitHub Actions workflow is configured to trigger on a push to either the dev or prod branch. The deployment is performed with the following steps:

S3 Bucket Creation:

If changes are pushed to the dev branch, it creates an S3 bucket named sam-cloudojo-dev.
If changes are pushed to the prod branch, it creates an S3 bucket named sam-cloudojo-prod.
File Upload:

The files from the k8s and infrastructure folders in your project are synced to the corresponding S3 bucket (either sam-cloudojo-dev or sam-cloudojo-prod).
SAM Deployment:

The sam deploy command is executed, which deploys the stack using the configuration defined in samconfig.toml.

### 5. **Deploy the Stack**

Push changes to the dev or prod branch.
The GitHub Actions workflow will automatically trigger:
It will create the S3 bucket if it doesn't already exist.
It will upload the relevant files from the project’s k8s manifests and infrastructure folders to the appropriate S3 bucket.
It will deploy the SAM stack to CloudFormation.
