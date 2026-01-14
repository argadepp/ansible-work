terraform {
  source = "git::https://github.com/argadepp/ansible-work.git?ref=test3"
}

inputs = {
  bucket_name    = "prtaik-argade-atlatis-bucket"
  tags = {
    auto-start-stop = "Yes"
    Environment = "dev"
    Owner       = "team-marvel"
    Project     = "Texa"
    CostCenter  = "CC1234"
    auto-start-stop = "Yes"
  }
}