include {
  path = find_in_parent_folders()
}

dependency "iam_role" {
  config_path = "./ssm_role"
}

inputs = {
  instance_type  = "t2.medium"
  name           = "master-server"
  ami            = "ami-0c2af51e265bd5e0e"
  filepath       = "/home/pratik/.ssh/salarypay"
  keyname        = "salarypay"
  aws_ssm_profile= dependency.iam_role.outputs.iam_instance_profile_name
  # Map of tags
  tags = {
    Environment = "dev"
    Owner       = "team-marvel"
    Project     = "Texa"
    CostCenter  = "CC1234"
  }
}