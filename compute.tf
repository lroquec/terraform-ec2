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