output "iam_instance_profile_name" {
  value = aws_iam_instance_profile.ec2_instance_profile.name
}

output "lambda_role" {
  value = aws_iam_role.lambda_execution_role.arn
}