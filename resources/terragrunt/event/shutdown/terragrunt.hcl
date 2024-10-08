dependency "iam_role" {
  config_path = "${get_repo_root()}/resources/terragrunt/ssm_role"
}

dependency "shutdownlambdaarn" {
  config_path = "${get_repo_root()}/resources/terragrunt/lambda/shutdown"
}

terraform {
  source = "${get_repo_root()}/resources/modules/eventbridge-schedule"
}

inputs = {
   cron-value = "0 16 * * ? *"
   targetid = "shutdown"
   lambdaarn = dependency.shutdownlambdaarn.outputs.lambdaarn
   function_name = "ec2_shutdown"
   rulename = "ec2_shutdown_8pm"
    tags = {
    Environment = "dev"
    Owner       = "team-marvel"
    Project     = "Texa"
    CostCenter  = "CC1234"
    auto-start-stop = "Yes"
  }
}
