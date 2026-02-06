# Launch Ephemeral Jenkins Agents

This repository contains the infrastructure as code (IaC) for provisioning, configuring, and destroying ephemeral Jenkins agents on AWS using Terraform. It is designed to automate the creation of EC2 instances configured as Jenkins agents, enabling scalable and parallel execution of CI/CD pipelines.

## Main Features

- **Automatic provisioning** of Jenkins agents on AWS EC2 using Terraform.
- **Security configuration** through Security Group modules.
- **Automatic installation** of dependencies and required tools for agents (Java, Docker, Maven, kubectl, AWS CLI, Terraform, etc.).
- **Jenkins integration** to launch, use, and destroy agents from pipelines (included Jenkinsfiles).
- **Ephemeral agent support**: agents are created on demand and automatically destroyed when jobs finish.
- **Secure SSH authentication** to private GitHub repository via Deploy Keys.
- **Ansible automation** for tool installation and configuration.

## Repository Structure

```bash
.
├── main.tf                      # Main Terraform configuration
├── variables.tf                 # Global Terraform variables
├── backend.tf                   # Remote Terraform backend configuration (S3)
├── modules/                     # Reusable Terraform modules
│   ├── ec2/                     # EC2 instance creation and bootstrap
│   │   ├── main.tf              # EC2 resource definition
│   │   ├── variables.tf         # Module variables
│   │   ├── outputs.tf           # EC2 outputs
│   │   └── agent_config.sh      # User data bootstrap script
│   └── sg/                      # Security Group module
│       ├── main.tf              # Security Group rules
│       ├── variables.tf         # Module variables
│       └── outputs.tf           # SG outputs
├── ansible/                     # Ansible configuration
│   ├── playbooks/
│   │   └── jenkins-agent.yaml   # Main playbook
│   └── roles/
│       └── jenkins-agent/       # Agent configuration role
│           ├── tasks/           # Installation tasks (AWS, kubectl, Docker, Jenkins, etc.)
│           ├── templates/       # Configuration templates
│           ├── defaults/        # Default variables
│           └── handlers/        # Handler definitions
```

## Prerequisites

### GitHub Repository Setup

1. **Generate SSH Deploy Key** on your local machine:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/github_deploy -C "jenkins-agent-deploy" -N ""
```

2. **Add Deploy Key to GitHub**:

- GitHub → Settings → Deploy keys → Add deploy key
- Paste contents of `~/.ssh/github_deploy.pub`
- Allow write access (optional)

3. **Store Deploy Key in Jenkins Credentials**:

- Jenkins → Manage Credentials → Add Credentials
- Kind: Secret text
- Secret: contents of `~/.ssh/github_deploy` (private key)
- ID: `GITHUB_DEPLOY_KEY`

### AWS Setup

- AWS account with permissions to create EC2, Security Groups, IAM profiles
- Configured VPC, Subnet, and Security Group
- IAM role with required permissions (S3, ECR, EKS, CloudWatch, etc.)

## Main Variables

Variables are defined in `variables.tf` and can be overridden via command line or `.tfvars` files:

| Variable                 | Description                                                           |
|-----------------------   |-----------------------------------------------------------------------|
| `github_deploy_key`      | GitHub SSH private key for accessing the repo (injected from Jenkins) |
| `jenkins_controller_url` | Jenkins controller URL                                                |
| `jenkins_agent_secret`   | Jenkins agent secret token                                            |
| `instance_name`          | EC2 instance name                                                     |
| `ami_id`                 | AMI ID for the EC2 instance                                           |
| `instance_type`          | EC2 instance type (default: `t3.large`)                               |
| `subnet_id`              | VPC Subnet ID for EC2 launch                                          |
| `eks_cluster_name`       | EKS cluster name                                                      |
| `aws_region`             | AWS region                                                            |
| `aws_id`                 | AWS account ID                                                        |
| `java_version`           | Java version to install (default: `11`)                               |
| `environment`            | Environment context (dev/staging/prod)                                |

## Basic Usage

1. Clone this repository and navigate to the root folder:

```bash
git clone git@github.com:juancamilocc/launch-ephemeral-jenkins-agents.git
cd launch-ephemeral-jenkins-agents
```

2. Initialize Terraform:

```bash
terraform init
```

3. Validate configuration:

```bash
terraform validate
```

4. Preview the changes:

```bash
terraform plan \
   -var="github_deploy_key=$(cat ~/.ssh/github_deploy)" \
   -var="instance_name=YOUR_INSTANCE_NAME" \
   -var="jenkins_agent_secret=YOUR_JENKINS_SECRET" \
   -var="jenkins_controller_url=https://jenkins.example.com" \
   -var="ami_id=YOUR_AMI_ID" \
   -var="subnet_id=subnet-12345678" \
   -var="eks_cluster_name=my-cluster" \
   -var="aws_region=us-east-1" \
   -var="aws_id=123456789012" \
   -var="environment=dev"
```

5. Apply the infrastructure:

```bash
terraform apply \
   -var="github_deploy_key=$(cat ~/.ssh/github_deploy)" \
   -var="instance_name=YOUR_INSTANCE_NAME" \
   -var="jenkins_agent_secret=YOUR_JENKINS_SECRET" \
   -var="jenkins_controller_url=https://jenkins.example.com" \
   -var="ami_id=YOUR_AMI_ID" \
   -var="subnet_id=subnet-12345678" \
   -var="eks_cluster_name=my-cluster" \
   -var="aws_region=us-east-1" \
   -var="aws_id=123456789012" \
   -var="environment=dev"
```

6. Destroy the agent when no longer needed:

```bash
terraform destroy \
   -var="github_deploy_key=$(cat ~/.ssh/github_deploy)" \
   -var="instance_name=YOUR_INSTANCE_NAME" \
   -var="jenkins_agent_secret=YOUR_JENKINS_SECRET" \
   -var="jenkins_controller_url=https://jenkins.example.com" \
   -var="ami_id=YOUR_AMI_ID" \
   -var="subnet_id=subnet-12345678" \
   -var="eks_cluster_name=my-cluster" \
   -var="aws_region=us-east-1" \
   -var="aws_id=123456789012" \
   -var="environment=dev"
```

## Jenkins Pipeline Integration

Example Jenkinsfile for launching ephemeral agents:

```groovy
pipeline {
    agent {
        node {label "$instance"}
    }
    environment {
        AGENT_NAME = "executor_${currentBuild.projectName}"
        AMI_ID = getAMIID() 
        GITHUB_DEPLOY_KEY = credentials('github-deploy-key')
    }
    stages{
        stage('Launch Executor Agent') {
            steps {
                script {

                    agentReady = isAgentOnline(AGENT_NAME)

                    if (!agentReady) {

                        echo "The agent is not ready, lauching agent using terraform..."

                        sh """
                            git clone -b ${environment} ${repository} && cd ${pathRepository}
                            
                            set +x
                            terraform init
                            terraform plan \
                                -var="github_deploy_key=${GITHUB_DEPLOY_KEY}" \
                                -var="instance_name=${AGENT_NAME}" \
                                -var="jenkins_agent_secret=${secretJenkinsAgent}" \
                                -var="ami_id=${AMI_ID}" \
                                -out=jenkins-agent
                            terraform apply "jenkins-agent"
                        """

                        sh 'rm -rf $pathRepository'

                    } else {

                        echo "The agent is already active and online..."
                    }
                }
            }
        }
        stage('Check Agent Status') {
            steps {
                script {
                    
                    def MAX_RETRIES = 60             
                    def RETRY_DELAY_SECONDS = 10
                    def agentReady = false
                    def retries = 0

                    echo "Waiting for '${AGENT_NAME}' agent is active..."

                    while (!agentReady && retries < MAX_RETRIES) {
                        
                        agentReady = isAgentOnline(AGENT_NAME)

                        if (!agentReady) {
                            retries++
                            echo "Retrying ${retries}/${MAX_RETRIES}: '${AGENT_NAME}' agent is not active. Waiting ${RETRY_DELAY_SECONDS} seconds..."
                            sleep RETRY_DELAY_SECONDS 
                        }
                    }

                    if (agentReady) {
                        
                        echo "The' ${AGENT_NAME}' agent is online and active..."
                    
                    } else {
                        
                        error "The '${AGENT_NAME}' agent is not active after ${MAX_RETRIES} attempts..."
                    }
                }
            }
        }
        stage('Execute Heavy Job') {
            steps {
                script {

                    // Execute Heavy job
            }
        }
    }
    post {
        success {
            echo "SUCCESS"
        }
        failure {
            echo "FAILURE"
        }
    }
}

def isAgentOnline(String agentName) {

    Node node = Jenkins.instance.getNode(agentName)
    if (node == null) {
        println("WARN: The '${agentName}' agent doesn't exist in Jenkins Server. Verify name...")
        return false 
    }

    Computer computer = node.toComputer()
    if (computer == null) {
        println("WARN: Computer agent not found to the agent '${agentName}'.")
        return false
    }

    if (computer.isOffline() || computer.isTemporarilyOffline() || computer.isConnecting()) {
        println("'${agentName}' agent is offline. Current status: ${computer.isOffline() ? 'OFFLINE' : (computer.isTemporarilyOffline() ? 'TEMPORALMENTE OFFLINE' : 'CONECTANDO')}. Cause: ${computer.getOfflineCause() ?: 'Any'}")
        return false
    }

    return true
}

def getAMIID() {

    def amiID = sh(
        script: 'aws ssm get-parameter \
            --name /aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id \
            --query "Parameter.Value" \
            --output text',
        returnStdout: true
    ).trim()

    return amiID
}
```

## Terraform Modules

### modules/sg

- **Purpose**: Creates the required Security Group for the agent
- **Rules**: Ingress rules for SSH (22), Jenkins agent communication (50000), and any required application ports

### modules/ec2

- **Purpose**: Creates the EC2 instance and bootstraps it with Jenkins agent configuration
- **User Data Script** (`agent_config.sh`):
  
- Creates `/root/.ssh` directory with correct permissions
- Injects SSH private key from `github_deploy_key` variable
- Adds GitHub to SSH `known_hosts` to avoid interactive prompts
- Installs Ansible
- Executes `ansible-pull` to clone the repository via SSH
- Runs Ansible playbook `jenkins-agent.yaml` to configure the agent
- Installs tools in order: Packages, Kubectl, AWS, Terraform, Docker and Jenkins config.

- **Instance Configuration**:
  - 100GB EBS volume (gp3)
  - IAM instance profile for AWS service access
