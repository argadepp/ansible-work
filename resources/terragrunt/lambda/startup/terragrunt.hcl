
dependency "iam_role" {
  config_path = "${get_repo_root()}/resources/terragrunt/ssm_role"
}


terraform {
  source = "${get_repo_root()}/resources/modules/lambda"
}

inputs = {
   lambda_role = dependency.iam_role.outputs.lambda_role
   function = "startup"
   function_name = "ec2_startup"
   bucket_name ="devoptech-dev-terraform-backend"

}
