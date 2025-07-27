resource "aws_security_group" "executor_agent_sg" {

    name_prefix = "executor-agent-sg"
    vpc_id      = var.vpc_id

    # 50000 port is default to connect agents
    ingress {

        from_port   = 50000 
        to_port     = 50000
        protocol    = "tcp"
        cidr_blocks = [var.jenkins_controller_ip_cidr]
        description = "Allow Access from Jenkins to connect agent"
    }

    # SSH key access
    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.ssh_ip_cidr] 
        description = "Allow SSH from my IP"
    }

    # Allow download any data from internet, to get software among others.
    egress {

        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}