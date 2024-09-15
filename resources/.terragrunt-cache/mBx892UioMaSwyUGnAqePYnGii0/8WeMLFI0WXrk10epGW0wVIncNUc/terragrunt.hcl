terraform {
  source = "modules/ec2"
}

inputs = {
  instance_type  = "t2.micro"
  name           = "ubuntu-node-new"
  
  # Map of tags
  tags = {
    Environment = "dev"
    Owner       = "team-flash"
    Project     = "Fus-c"
    CostCenter  = "CC1234"
  }
}