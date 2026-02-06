variable "ami_id" {
    
    description = "ID of the AMI to use for the instance"
    type        = string
}

variable "instance_type" {
    
    description = "Type of instance to start"
    type        = string
}

variable "subnet_id" {
    
    description = "VPC Subnet ID to launch in"
    type        = string
}

variable "key_name" {
    
    description = "Key name of the Key Pair to use for the instance"
    type        = string
}

variable "instance_name" {
  
    description = "Name to be used on EC2 instance created"
    type        = string
}

variable "jenkins_controller_url" {
  
    description = "URL of the Jenkins controller"
    type        = string
}

variable "jenkins_agent_secret" {
  
    description = "Secret for the Jenkins agent"
    type        = string
    sensitive   = true
}

variable "remote_fs_root" {
  
    description = "Remote filesystem root for Jenkins agent"
    type        = string
}

variable "java_version" {

    description = "Java Version"
    type        = string
}

variable "sg_id" {

    description = "Security Group ID"
    type        = string
}

variable "iam_instance_profile_name" {

    description = "Instance profile name of IAM role"
    type        = string
}

variable "eks_cluster_name" {

    description = "EKS cluster name"
    type        = string
}

variable "aws_region" {

    description = "AWS region"
    type        = string
}

variable "aws_id" {

    description = "AWS id"
    type        = string
}

variable "environment" {

    description = "Environment context"
    type        = string
}

variable "github_deploy_key" { # This must be a SSH key passed in the pipeline

    description = "GitHub deploy key for private repository access"
    type        = string
    sensitive   = true
}