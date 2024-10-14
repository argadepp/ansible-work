terraform {
  source = "${get_repo_root()}/resources/modules/s3"
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