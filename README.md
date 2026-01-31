# Cloud Web Application Deployment

This project demonstrates how to deploy a cloud-native web application using containerization via AWS ECS Fargate and Terraform and GitHub Actions CI/CD pipeline, which follows infrastructure as code (IaC) principles. The system achieves consistent, repeatable, and scalable provisioning of AWS resources, and automatically deploys the Dockerized application to ECS Fargate after every master branch update after its build and push to Amazon ECR.

Key Highlights ----------

1. Serverless container deployment using AWS ECS Fargate
2. Infrastructure provisioning using Terraform
3. Application containerization with Docker
4. Automated CI/CD pipeline using GitHub Actions
5. Secure AWS access via GitHub OIDC authentication
6. Container image storage in Amazon Elastic Container Registry (ECR)
7. IAM roles and security groups configured using best practices
8. Centralized logging with Amazon CloudWatch
9. Public access enabled through task public IP (Load Balancer optional)

System Architecture Overview ----------

1. The solution consists of the following AWS components:
2. Virtual Private Cloud (VPC) with public subnets
3. Amazon ECS Cluster using Fargate
4. ECS Task Definitions and Services
5. Amazon ECR for container image storage
6. IAM Roles and Policies for secure access
7. Security Groups to control network traffic
8. CloudWatch Log Groups for application monitoring

CI/CD Pipeline Workflow ----------
1. Developer pushes code changes to the main branch
2. GitHub Actions workflow is triggered automatically
3. Application Docker image is built
4. Docker image is tagged and pushed to Amazon ECR
5. Terraform provisions or updates AWS infrastructure
6. ECS task definition is updated with the new image
7. ECS service deploys the updated task revision
8. Deployment completes after service reaches a stable state

Repository Structure ----------


1. ├── app.py                - Application source code
2. ├── Dockerfile            - Docker image build instructions
3. ├── requirements.txt      - Application dependencies
4. ├── webui/                - Application user interface
5. ├── static/               - Static assets (CSS, JS)
6. ├── terraform/            - Terraform infrastructure configuration
7. ├── .github/workflows/    - GitHub Actions CI/CD pipeline
8. └── README.md             - Project documentation

