# Create IAM Role for EC2
resource "aws_iam_role" "ec2_ssm_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "sts:AssumeRole",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
      }
    ]
  })
  tags = merge({Name= var.role_name},var.tags)
}

# Attach the AmazonSSMManagedInstanceCore policy to the IAM Role
resource "aws_iam_role_policy_attachment" "ssm_policy_attach" {
  role       = aws_iam_role.ec2_ssm_role.name
  policy_arn = var.policy_arn
}

# Create an instance profile to attach to the EC2 instance
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = aws_iam_role.ec2_ssm_role.name
  role = aws_iam_role.ec2_ssm_role.name
}
