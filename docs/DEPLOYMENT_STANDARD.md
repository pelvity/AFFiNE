# AFFiNE Deployment Standard (Terraform & ECR)

This document outlines the modern, industry-standard infrastructure and deployment pipeline for AFFiNE.

## Architecture Overview

*   **Infrastructure as Code (IaC)**: AWS resources are managed by **Terraform**.
*   **Container Registry**: Docker images are built outside of EC2 and pushed to **Amazon ECR**.
*   **Compute**: **Amazon EC2** pulls pre-built images from ECR using an IAM Instance Profile (no AWS keys stored on the server).
*   **Orchestration**: `docker-compose.prod.yml` remains the engine, but is fed image URLs rather than building from source.

## File Locations

*   `terraform/`: Contains all infrastructure definitions (`main.tf`, `iam.tf`, `variables.tf`, `outputs.tf`).
*   `.github/workflows/build-and-push-ecr.yml`: Automates building and pushing to ECR on `main` branch merges.
*   `scripts/build-and-push-local.sh`: A local alternative to GitHub Actions using your `aws-poco` isolated credentials.
*   `scripts/deploy-from-ecr.sh`: Remotely triggers the EC2 instance to pull the newly built image and restart.

## How to Provision Infrastructure (First Time)

1.  Navigate to the terraform directory: `cd terraform`
2.  Initialize terraform: `terraform init`
3.  Deploy the infrastructure: `terraform apply`
    *   *Note: This will use your `~/.aws-poco/credentials` automatically.*

## How to Deploy Updates

You have two options to build the Docker image:

### Option A: GitHub Actions (Recommended)
1. Push your code to the `main` branch.
2. Ensure you have added `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to your GitHub Repository Secrets (using an IAM user with ECR push permissions).
3. The Action will build and push the image.
4. Run `./scripts/deploy-from-ecr.sh` locally to tell EC2 to pull and restart.

### Option B: Local Build & Push
If you prefer to build locally using your `aws-poco` credentials:
1. Run `./scripts/build-and-push-local.sh`
   * *This will build the image on your machine and push it to ECR.*
2. Run `./scripts/deploy-from-ecr.sh` locally to tell EC2 to pull and restart.

## Security Improvements
*   **IAM Roles over Keys**: EC2 authenticates to ECR via an assigned IAM Instance Profile, eliminating the need to store AWS access keys on the server.
*   **Separation of Concerns**: EC2 no longer wastes CPU/Memory compiling the Node.js source code. It only runs the final binary.
