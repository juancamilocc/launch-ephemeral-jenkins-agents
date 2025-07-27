variable "vpc_id" {
    
    description = "ID of the VPC where the security group will be created"
    type        = string
}

variable "jenkins_controller_ip_cidr" {
    
    description = "CIDR block of the Jenkins controller for ingress rules"
    type        = string
}

variable "ssh_ip_cidr" {
    
    description = "CIDR block of the SSH key for ingress rules"
    type        = string
}