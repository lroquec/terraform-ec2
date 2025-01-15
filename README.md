# AWS Apache Proxy Server Terraform Module

This Terraform module deploys an Apache HTTP server configured as a reverse proxy with Docker support on AWS. The module creates a complete infrastructure including VPC, subnets, security groups, and an EC2 instance with necessary IAM roles.

## Features

- VPC with configurable public and private subnets
- EC2 instance running Amazon Linux 2023
- Apache HTTP server configured as reverse proxy
- Docker support
- AWS Systems Manager (SSM) integration
- AWS CodeDeploy agent pre-installed
- Free tier compatible

## Prerequisites

- AWS account
- Terraform >= 1.0
- AWS provider configured

## Usage

```hcl
module "apache_proxy_docker" {
  source        = "path/to/module"
  project_name  = "my-project"
  instance_type = "t2.micro"
  environment   = "dev"
  tags = {
    Owner = "devops-team"
    Name  = "my-project-ec2-instance"
  }
}
```

## Multi-Environment Example

```hcl
module "apache_proxy_docker_staging" {
  source        = "./apache_proxy_server_module"
  project_name  = var.project_name
  instance_type = "t2.micro"
  environment   = "staging"
  tags = {
    Owner = "devops-team"
    Name  = "${var.project_name}-ec2-instance"
  }
}

module "apache_proxy_docker_dev" {
  source        = "./apache_proxy_server_module"
  project_name  = var.project_name
  instance_type = "t2.micro"
  environment   = "dev"
  tags = {
    Owner = "devops-team"
    Name  = "${var.project_name}-ec2-instance"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| project_name | The name of the project | string | - | yes |
| vpc_cidr | The CIDR block for the VPC | string | "10.0.0.0/16" | no |
| subnet_config | Map of subnet configurations | map(object) | See below | no |
| instance_type | The instance type for the EC2 instance | string | "t2.micro" | no |
| tags | Additional tags for all resources | map(string) | {} | no |
| environment | Environment name (e.g. dev, prod, staging) | string | "dev" | no |

### Default Subnet Configuration

```hcl
{
  subnet1 = {
    cidr_block = "10.0.1.0/24"
    public     = true
  }
  subnet2 = {
    cidr_block = "10.0.2.0/24"
    public     = false
  }
}
```

## Outputs

| Name | Description |
|------|-------------|
| vpc_cidr | The VPC ID |
| first_public_subnet_id | The ID of the first public subnet |
| ec2_instance_id_public_ip | The public IP address of the EC2 instance |

## Apache Configuration

The module configures Apache with the following features:
- Reverse proxy setup for Docker containers (proxying /docker to localhost:5000)
- HTTP traffic enabled (port 80)
- Custom logging configuration
- Load balancing ready

## Security

- Inbound traffic allowed only on port 80
- All outbound traffic allowed
- SSM access enabled for secure instance management
- Security groups properly configured

## Limitations

- Instance type is restricted to t2.micro for free tier compatibility
- Only HTTP traffic is supported (no HTTPS configuration)
- Single instance deployment (no auto-scaling)

## Tags

All resources are tagged with:
- Environment (from var.environment)
- Managed by: Terraform
- Cost Center: FreeTier
- Additional custom tags as specified in var.tags

## Additional Notes

- The module uses the latest Amazon Linux 2023 AMI
- System packages are updated during installation
- Docker is configured to allow non-root user access
- CodeDeploy agent is installed for deployment automation