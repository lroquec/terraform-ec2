####### tfstate #######

terraform {
  backend "s3" {
    bucket = "lroquec-tf"
    key    = "apache-proxy-server/terraform.tfstate"
    region = "us-east-1"
  }
}

####### variables #######
variable "project_name" {
  description = "The name of the project"
  type        = string

}
variable "instance_type" {
  description = "The instance type to use for the EC2 instance"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = var.instance_type == "t2.micro"
    error_message = "The instance type must be a t2.micro for staying within the free tier"
  }

}
####### modules #######
module "apache_proxy_docker_staging" {
  source        = "./apache_proxy_server_module"
  project_name  = var.project_name
  instance_type = var.instance_type
  environment   = "staging"
  tags = {
    Owner = "devops-team"
    Name  = "${var.project_name}-ec2-instance"
  }
}

module "apache_proxy_docker_dev" {
  source        = "./apache_proxy_server_module"
  project_name  = var.project_name
  instance_type = var.instance_type
  environment   = "dev"
  tags = {
    Owner = "devops-team"
    Name  = "${var.project_name}-ec2-instance"
  }
}
###### outputs #######
output "apache_proxy_docker_staging_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = module.apache_proxy_docker_staging.ec2_instance_id_public_ip

}

output "apache_proxy_docker_dev_public_ip" {
  description = "The public IP address of the EC2 instance"
  value       = module.apache_proxy_docker_dev.ec2_instance_id_public_ip

}