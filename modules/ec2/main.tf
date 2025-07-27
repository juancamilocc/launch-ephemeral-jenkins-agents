resource "aws_instance" "executor_agent" {
    
    ami                     = var.ami_id
    instance_type           = var.instance_type
    iam_instance_profile    = var.iam_instance_profile_name

    instance_market_options {
        
        market_type = "spot"
        
        spot_options {
            instance_interruption_behavior = "terminate"
        }
    }

    root_block_device {
    
        volume_size = 100  
        volume_type = "gp3" 
        delete_on_termination = true
    }

    subnet_id               = var.subnet_id
    vpc_security_group_ids  = [var.sg_id]
    key_name                = var.key_name

    # Pass variables for setting up instance as an agent and install requirements
    user_data = base64encode(templatefile("${path.module}/agent_config.sh", {
        
        jenkins_controller_url      = var.jenkins_controller_url
        jenkins_agent_name          = var.instance_name
        jenkins_agent_secret        = var.jenkins_agent_secret
        remote_fs_root              = var.remote_fs_root
        java_version                = var.java_version
        kubectl_version             = var.kubectl_version
        eks_cluster_name            = var.eks_cluster_name
        aws_region                  = var.aws_region
        aws_id                      = var.aws_id
        environment                 = var.environment
    }))

    tags = {
        Name = var.instance_name
    }
}