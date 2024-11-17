output "vpc_cidr" {
  description = "The VPC Id"
  value       = module.vpc.vpc_id
}

output "first_public_subnet_id" {
  description = "The ID of the first public subnet"
  value       = module.vpc.public_subnets[0]
  
}