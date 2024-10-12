dependency "iam_role" {
  config_path = "${get_repo_root()}/resources/terragrunt/ssm_role"
}

terraform {
  source = "${get_repo_root()}/resources/modules/ec2"
}

inputs = {
  instance_type   = "t2.micro"
  name            = "atlantis-server"
  ami             = "ami-0c2af51e265bd5e0e"
  filepath        = "/home/pratik/.ssh/salarypay"
  keyname         = "salarypay"
  aws_ssm_profile = dependency.iam_role.outputs.iam_instance_profile_name
  tags = {
    auto-start-stop = "Yes"
    Environment = "dev"
    Owner       = "team-marvel"
    Project     = "Texa"
    CostCenter  = "CC1234"
    auto-start-stop = "Yes"
  }
}
