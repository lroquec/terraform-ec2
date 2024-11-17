data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"] # Amazon Linux AMIs are owned by AWS

  filter {
    name   = "name"
    values = ["Amazon Linux"] # Filter for Amazon Linux 2 AMIs
  }
  filter {
    name   = "architecture"
    values = ["x86_64"] # Filter for 64-bit architecture
  }
}