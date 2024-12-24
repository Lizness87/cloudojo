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

Technical Decisions
1. Choice of GitHub Actions for Deployment
GitHub Actions was chosen for automating the deployment of the SAM stack for several reasons:

Seamless CI/CD Integration: GitHub Actions integrates directly with the GitHub repository, providing a streamlined process for continuous integration and deployment (CI/CD). This minimizes manual intervention and ensures that any code changes trigger automatic builds and deployments.

Multi-Environment Support: With GitHub Actions, it’s easy to configure separate workflows for different environments (dev, prod). By using branch-specific deployments, I can control which environment the stack is deployed to based on the branch pushed to, ensuring that dev and prod environments are separated.

Cost-Effective: GitHub Actions is free for public repositories and offers a generous free tier for private repositories, making it a cost-effective choice for CI/CD automation.

Scalability: GitHub Actions workflows can be easily extended or modified to handle additional environments, deployment steps, or other tasks, which makes it a scalable solution as the project grows.

2. Scaling Behavior and Horizontal Pod Autoscaling for PHP Application
The PHP application in this setup uses Kubernetes' Horizontal Pod Autoscaler (HPA) to automatically scale based on resource utilization, ensuring that the app can handle varying loads efficiently.

Scaling Based on Resource Utilization: The PHP application will scale when the average CPU or memory usage reaches 70%. This allows for dynamic scaling based on demand, ensuring the app can handle increased traffic and scale down when the load is low.

Resource Requests and Limits: The application has defined resource requests and limits to ensure that each pod gets enough resources to run smoothly. The requests define the minimum resources required for the pod, and the limits ensure that the pod will not exceed these resources, preventing resource contention.
Expected Scaling Behavior:
Low Traffic: When traffic is low, the application will scale down to 1 replica to save resources.

High Traffic: As CPU or memory usage exceeds the 70% utilization threshold, the HPA will scale the number of replicas up to 3, ensuring the application can handle increased demand.

Max Scaling: The application can scale up to a maximum of 3 replicas, as defined by the maxReplicas setting in the HPA.