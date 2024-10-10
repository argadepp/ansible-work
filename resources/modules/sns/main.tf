# Create SNS topic
resource "aws_sns_topic" "ami_notifications" {
  name = "ami-notifications-topic"
}

# Create SNS subscription (for email)
resource "aws_sns_topic_subscription" "email_subscription" {
  topic_arn = aws_sns_topic.ami_notifications.arn
  protocol  = "email"
  endpoint  = "argadepp@gmail.com"  # Replace with your email address
}

# Create IAM role for Lambda with SNS publish permissions
resource "aws_iam_role" "lambda_iam_role" {
  name = "lambda-sns-publish-role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action    = "sts:AssumeRole",
        Effect    = "Allow",
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Attach SNS publish policy to the Lambda role
resource "aws_iam_policy" "lambda_sns_policy" {
  name        = "lambda-sns-publish-policy"
  description = "Policy to allow Lambda to publish to SNS"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = "sns:Publish",
        Effect   = "Allow",
        Resource = aws_sns_topic.ami_notifications.arn
      }
    ]
  })
}

# Attach the policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_sns_policy_attach" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_sns_policy.arn
}

# Lambda function to fetch AMI details and publish to SNS
resource "aws_lambda_function" "fetch_ami_and_notify" {
  filename         = "./bottlerocket.zip" # Path to your packaged Lambda function code
  function_name    = "fetch-ami-details-and-notify"
  role             = aws_iam_role.lambda_iam_role.arn
  handler          = "bottlerocket.lambda_handler"
  runtime          = "python3.9"
  
  environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.ami_notifications.arn
    }
  }
  
  # Lambda Timeout and Memory can be adjusted based on your needs
  timeout = 30
  memory_size = 128
}

# Lambda permissions to allow it to be invoked by specific triggers
resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fetch_ami_and_notify.function_name
  principal     = "sns.amazonaws.com"
}

resource "aws_iam_role_policy" "lambda_ssm_policy" {
  name = "lambda_ssm_policy"
  role = aws_iam_role.lambda_iam_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = "ssm:GetParameter",
        Resource = "arn:aws:ssm:ap-south-1::parameter/aws/service/bottlerocket/aws-k8s-1.29/x86_64/latest/*"
      }
    ]
  })
}
