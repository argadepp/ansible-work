dependency "iam_role" {
  config_path = "${get_repo_root()}/resources/terragrunt/ssm_role"
}

dependency "startlambdaarn" {
  config_path = "${get_repo_root()}/resources/terragrunt/lambda/startup"
}

terraform {
  source = "${get_repo_root()}/resources/modules/eventbridge-schedule"
}

inputs = {
   cron-value = "0 6 * * ? *"
   targetid = "startup"
   lambdaarn = dependency.startlambdaarn.outputs.lambdaarn
   function_name = "ec2_startup"
   rulename = "ec2_startup_6am"
     tags = {
    Environment = "dev"
    Owner       = "team-marvel"
    Project     = "Texa"
    CostCenter  = "CC1234"
    auto-start-stop = "Yes"
  }
}
