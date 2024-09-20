dependency "iam_role" {
  config_path = "${get_repo_root()}/resources/terragrunt/ssm_role"
}


terraform {
  source = "${get_repo_root()}/resources/modules/lambda"
}

inputs = {
   lambda_role = dependency.iam_role.outputs.lambda_role
   function = "shutdown"
   function_name = "ec2_shutdown"
   bucket_name ="devoptech-dev-terraform-backend"

}
