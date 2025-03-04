locals {
  project_name = var.project_name
  private_subnets_cidr = [for k, v in var.subnet_config : v.cidr_block if !v.public]
  public_subnets_cidr  = [for k, v in var.subnet_config : v.cidr_block if v.public]
  common_tags = {
    env       = var.environment
    managedby = "Terraform"
  }
}
data "aws_availability_zones" "azs" {
  state = "available"
}
module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.5.3"

  name                    = "${local.project_name}-vpc"
  cidr                    = var.vpc_cidr
  azs                     = data.aws_availability_zones.azs.names
  private_subnets         = local.private_subnets_cidr
  public_subnets          = local.public_subnets_cidr
  map_public_ip_on_launch = true

  tags = merge(local.common_tags, {
    "CostCenter" = "FreeTier"
  })
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"] # Amazon Linux AMIs are owned by AWS

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"] # Filter for 64-bit architecture
  }
}

resource "aws_instance" "web" {
  ami                  = data.aws_ami.latest_amazon_linux.id
  instance_type        = var.instance_type
  subnet_id            = module.vpc.public_subnets[0]
  security_groups      = [aws_security_group.allow_http_inbound.id]
  iam_instance_profile = aws_iam_instance_profile.ec2instanceprofile.name
  user_data            = file("${path.module}/templates/user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
  tags = merge(local.common_tags, {
    Name = "${local.project_name}-${var.environment}-ec2-instance"
  })
}

resource "aws_security_group" "allow_http_inbound" {
  vpc_id = module.vpc.vpc_id
  tags = merge(local.common_tags, {
    Name = "${local.project_name}-allow-http-sg"
  })
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_http_inbound.id
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.allow_http_inbound.id
}

# Create and instance profile with SSM permissions
resource "aws_iam_instance_profile" "ec2instanceprofile" {
  name = "${var.project_name}-${var.environment}-instance-profile"
  role = aws_iam_role.ec2instanceprofile.name
}

resource "aws_iam_role" "ec2instanceprofile" {
  name = "${var.project_name}-${var.environment}-instance-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  tags = merge(local.common_tags, {
    Name = "${var.project_name}-instance-role"
  })
}

data "aws_iam_policy" "ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = data.aws_iam_policy.ssm.arn
  role       = aws_iam_role.ec2instanceprofile.name
}