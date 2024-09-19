# Root terragrunt.hcl for shared configuration
terraform {
  # This specifies the source for the Terraform code, e.g., where to find the modules
  source = "./../modules/${path_relative_to_include()}"
}


generate "backend" {
  path      = "backend.tf"
  if_exists = "overwrite_terragrunt"
  contents = <<EOF
terraform {
  backend "s3" {
    bucket         = "devoptech-dev-terraform-backend"
    key            = "${path_relative_to_include()}/terraform.tfstate"
    region         = "ap-south-1"
    encrypt        = true
  }
}
EOF
}
