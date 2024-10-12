
terraform {
  source = "${get_repo_root()}/resources/modules/lambda"
}
inputs = {
   function = "startup"
   function_name = "ec2_startup"
   bucket_name ="devoptech-dev-terraform-backend"

}
