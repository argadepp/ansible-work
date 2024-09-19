terraform {
  source = "./modules/ec2"
}

inputs = {
  instance_type  = "t2.medium"
  name           = "salarypay"
  ami            = "ami-0838bc34dd3bae25e"
  filepath       = "/home/pratik/.ssh/salarypay"
  keyname        = "salarypay"
  # Map of tags
  tags = {
    Environment = "dev"
    Owner       = "team-marvel"
    Project     = "Texa"
    CostCenter  = "CC1234"
  }
}