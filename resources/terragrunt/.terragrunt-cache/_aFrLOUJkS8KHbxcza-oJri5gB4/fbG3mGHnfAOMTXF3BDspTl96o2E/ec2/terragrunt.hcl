include {
  path = find_in_parent_folders()
}

dependency "iam_role" {
  config_path = "../iam_role"
}


inputs = {
  instance_type  = "t2.medium"
  name           = "salarypay"
  ami            = "ami-0522ab6e1ddcc7055"
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