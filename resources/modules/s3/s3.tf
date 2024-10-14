resource "aws_s3_bucket" "test_bucket" {
  bucket = var.bucket_name
  tags = merge({Name= var.bucket_name},var.tags)
}