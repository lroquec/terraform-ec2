output "vpc_cidr" {
  description = "The VPC Id"
  value       = module.vpc.vpc_id
}

output "first_public_subnet_id" {
  description = "The ID of the first public subnet"
  value       = module.vpc.public_subnets[0]

}

output "ec2_instance_id_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = aws_instance.web.public_ip

}