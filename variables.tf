# Variables backend and provider
variable "aws_region" {

  description = "AWS region"
  type        = string
  default     = "<YOUR_AWS_REGION>"
}

variable "aws_profile" {

  description = "AWS profile"
  type        = string
  default     = "default"
}

# Variables EC2 module
variable "ami_id" {
  
  description = "ID AMI for EC2 instance"
  type        = string
}

variable "instance_type" {

  description = "EC2 instance type"
  type        = string
  default     = "t3a.2xlarge"
}

variable "instance_name" {

  description = "EC2 instance name"
  type        = string
}

variable "jenkins_controller_url" {
  
  description = "Jenkins URL"
  type        = string
  default     = "<YOUR_JENKINS_CONTROLLER_URL>"
}

variable "jenkins_agent_secret" {

  description = "Generated secret for jenkins agent"
  type        = string
  sensitive   = true
}

variable "subnet_id" {
    
  description = "ID of the subnet where the EC2 instance will be launched."
  type        = string
  default     = "<SUBNET_TO_LAUNCH_YOUR_EC2_INSTANCE>"
}

variable "key_name" {

  description = "SSH Key to access to EC2"
  type        = string
  default     = "jenkins-agent-key"
}

variable "remote_fs_root" {

  description = "Jenkins Agent path where it will save agent file configuration"
  type        = string
  default     = "/var/lib/jenkins_agent"
}

variable "java_version" {

  description = "Java Version"
  type        = string
  default     = "11"
}

variable "iam_instance_profile_name" {

  description = "Instance profile name of IAM role"
  type        = string
  default     = "jenkins-agent-role"
}

variable "eks_cluster_name" {

  description = "EKS cluster name"
  type        = string
  default     = "<NAME_EKS_CLUSTER>"
}

variable "aws_id" {

  description = "AWS id"
  type        = string
  default     = "<YOUR_AWS_ID_ACCOUNT>"
}

variable "environment" {

  description = "Environment context"
  type        = string
  default     = "testing"
}

variable "github_deploy_key" { # This must be a SSH key passed in the pipeline
    
  description = "GitHub deploy key for private repository access"
  type        = string
  sensitive   = true
}

# Variables sg module
variable "vpc_id" {

  description = "ID of the VPC where the security group will be created"
  type        = string
  default     = "<VPC_ID>"
}

variable "jenkins_controller_ip_cidr" {

  description = "CIDR block of the Jenkins controller for ingress rules"
  type        = string
  default     = "<CIDR_IP>"
}

variable "ssh_ip_cidr" {
    
  description = "CIDR block of the SSH key for ingress rules"
  type        = string
  default     = "<YOUR_IP_TO_USE_SSH_KEY>"
}
