
resource "aws_lambda_function" "ec2_shutdown" {
  function_name = var.function_name
  
  s3_bucket        = var.bucket_name  # Replace with your S3 bucket name
  s3_key           = "lambda/${var.function_name}.zip"  # Replace with your S3 object key

  role             = var.lambda_role
  handler          = "lambda_function.lambda_handler"  # Adjust based on your code's handler
  runtime          = "python3.8"  # Adjust based on your runtime

  source_code_hash = filebase64sha256("./${var.function}/${var.function_name}.zip")  # Path to your zipped Lambda code
}

output "lambdaarn" {
  value = aws_lambda_function.ec2_shutdown.arn
}