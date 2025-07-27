provider "aws" {

    region  = var.aws_region
    profile = var.aws_profile
}


module "sg" {
    
    source                      = "./modules/sg"
    jenkins_controller_ip_cidr  = var.jenkins_controller_ip_cidr
    vpc_id                      = var.vpc_id
    ssh_ip_cidr                 = var.ssh_ip_cidr
}

module "ec2" {

    source                      = "./modules/ec2"
    ami_id                      = var.ami_id
    instance_type               = var.instance_type
    instance_name               = var.instance_name
    jenkins_controller_url      = var.jenkins_controller_url
    jenkins_agent_secret        = var.jenkins_agent_secret
    subnet_id                   = var.subnet_id
    key_name                    = var.key_name
    remote_fs_root              = var.remote_fs_root
    java_version                = var.java_version
    kubectl_version             = var.kubectl_version
    iam_instance_profile_name   = var.iam_instance_profile_name
    eks_cluster_name            = var.eks_cluster_name
    aws_region                  = var.aws_region
    aws_id                      = var.aws_id
    environment                 = var.environment
    sg_id                       = module.sg.sg_id
}