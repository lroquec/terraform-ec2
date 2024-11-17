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
  user_data            = <<-EOF
              #!/bin/bash
              yum update -y
              yum install wget ruby httpd docker -y
              echo "LoadModule proxy_module modules/mod_proxy.so" >> /etc/httpd/conf/httpd.conf
              echo "LoadModule proxy_http_module modules/mod_proxy_http.so" >> /etc/httpd/conf/httpd.conf
              echo "<h1>Deployed via Terraform</h1><br>Hostname: $(hostname)<br>Private IP: $(hostname -I | awk '{print $1}')" > /var/www/html/index.html
              cat <<EOT > /etc/httpd/conf.d/reverse-proxy.conf
              <VirtualHost *:80>
                  ServerAlias *
                  ProxyPreserveHost On
                  ProxyPass /docker http://localhost:5000/
                  ProxyPassReverse /docker http://localhost:5000/
                  RequestHeader set X-Forwarded-Proto "http"
                  RequestHeader set X-Forwarded-Port "80"
                  ErrorLog /var/log/httpd/docker_error.log
                  CustomLog /var/log/httpd/docker_access.log combined
              </VirtualHost>
              EOT
              systemctl enable httpd --now
              systemctl enable docker --now
              usermod -aG docker ec2-user
              cd /home/ec2-user 
              wget https://aws-codedeploy-us-east-1.s3.us-east-1.amazonaws.com/latest/install 
              chmod +x ./install
              ./install auto
              systemctl enable codedeploy-agent --now
              EOF

  lifecycle {
    create_before_destroy = true
  }
  tags = merge(local.common_tags, {
    Name = "${local.project_name}-ec2-instance"
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
  name = "myinstanceprofile-web-tf"
  role = aws_iam_role.ec2instanceprofile.name
}

resource "aws_iam_role" "ec2instanceprofile" {
  name = "roleforinstanceprofile-tf"
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
    Name = "roleforinstanceprofile-${local.project_name}"
  })
}

data "aws_iam_policy" "ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "ssm" {
  policy_arn = data.aws_iam_policy.ssm.arn
  role       = aws_iam_role.ec2instanceprofile.name
}