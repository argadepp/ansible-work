terraform {
  source = "${get_repo_root()}/resources/modules/ssm_role"
}
inputs = {
  role_name  = "master-server"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  tags = {
    Environment = "dev"
    Owner       = "team-marvel"
    Project     = "Texa"
    CostCenter  = "CC1234"
  }
}