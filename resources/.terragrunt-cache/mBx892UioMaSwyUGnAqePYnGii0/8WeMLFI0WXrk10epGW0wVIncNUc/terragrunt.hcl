terraform {
  source = "modules/ec2"
}

inputs = {
  instance_type  = "t2.micro"
  name           = "ubuntu-node-new"
  
  # Map of tags
  tags = {
    Environment = "dev"
    Owner       = "team-marvel"
    Project     = "Texa"
    CostCenter  = "CC1234"
  }
}