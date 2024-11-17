locals {
  project_name = var.project_name 
  common_tags = {
    env     = "dev"
    managed = "Terraform"
  }
}