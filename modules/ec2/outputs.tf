output "ec2_instance_id" {
    
    value = aws_instance.executor_agent.id
}