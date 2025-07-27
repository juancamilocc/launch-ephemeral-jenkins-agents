# Launch Ephemeral Jenkins Agents

This repository contains the infrastructure as code (IaC) for provisioning, configuring, and destroying ephemeral Jenkins agents on AWS using Terraform. It is designed to automate the creation of EC2 instances configured as Jenkins agents, enabling scalable and parallel execution of CI/CD pipelines.

## Main Features

- **Automatic provisioning** of Jenkins agents on AWS EC2 using Terraform.
- **Security configuration** through Security Group modules.
- **Automatic installation** of dependencies and required tools for agents (Java, Docker, Maven, kubectl, AWS CLI, etc.).
- **Jenkins integration** to launch, use, and destroy agents from pipelines (included Jenkinsfiles).
- **Ephemeral agent support**: agents are created on demand and automatically destroyed when jobs finish.

## Repository Structure

```bash
.
├── main.tf                      # Main Terraform configuration
├── variables.tf                 # Global Terraform variables
├── backend.tf                   # Remote Terraform backend configuration (S3)
├── modules/                     # Reusable Terraform modules
│   ├── ec2/                     # Module to create and configure the EC2 agent instance
│   └── sg/                      # Module for the agent's Security Group
└── ...
```

## Main Variables

Variables are defined in `variables.tf` and can be overridden via command line or `.tfvars` files. Some important ones:

- `aws_region`: AWS region
- `ami_id`: AMI ID for the agent
- `jenkins_controller_url`: Jenkins controller URL
- `jenkins_agent_secret`: Generated secret for the Jenkins agent
- `subnet_id`, `vpc_id`, `key_name`: Network and access
- `java_version`, `kubectl_version`, `eks_cluster_name`: Tool versions and context

**IMPORTANT:** Replace `<YOUR_AWS_ID_ACCOUNT>, <YOUR_AWS_REGION> <YOUR_JENKINS_CONTROLLER_URL>, <VPC_ID>, <CIDR_IP>, <YOUR_IP_TO_USE_SSH_KEY> and <SUBNET_TO_LAUNCH_YOUR_EC2_INSTANCE>` with your real values.

## Basic Usage

1. Clone this repository and go to the root folder.
2. Initialize Terraform:

   ```bash
   terraform init
   ```

3. Preview the changes:

   ```bash
   terraform plan -var="instance_name=AGENT_NAME" -var="jenkins_agent_secret=SECRET" -var="ami_id=AMI_ID"
   ```

4. Apply the infrastructure:

   ```bash
   terraform apply -var="instance_name=AGENT_NAME" -var="jenkins_agent_secret=SECRET" -var="ami_id=AMI_ID"
   ```

5. (Optional) Destroy the agent when it is no longer needed:

   ```bash
   terraform destroy -var="instance_name=AGENT_NAME" -var="jenkins_agent_secret=SECRET" -var="ami_id=AMI_ID"
   ```

## Terraform Modules

- **modules/sg**: Creates the required Security Group for the agent.
- **modules/ec2**: Creates the EC2 instance, installs dependencies, and configures the Jenkins agent.
