include {
  path = find_in_parent_folders()
}

inputs = {
  role_name  = "master-server"
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore" 
}

// inputs = {
//   instance_type  = "t2.micro"
//   name           = "web-node-new"
//   ami            = "ami-0e53db6fd757e38c7"
//   filepath       = "/home/pratik/.ssh/webserver"
//   keyname        = "webserver"
//   # Map of tags
//   tags = {
//     Environment = "dev"
//     Owner       = "team-marvel"
//     Project     = "Texa"
//     CostCenter  = "CC1234"
//   }
// }