

# Create SNS topic
resource "aws_sns_topic" "ami_notifications" {
  name = "ami-notifications-topic"
}

resource "archive_file" "bottlerocketzip" {
  type = "zip"
  source_file = "bottlerocket.py"
  output_path = "bottlerocket.zip"
}
variable "email_subscription" {
  type = list(string)
  default = ["argadepp@gmail.com" , "vishalbobade9376@gmail.com"]
}

# Create SNS subscription (for email)
resource "aws_sns_topic_subscription" "email_subscription" {
  for_each = toset(var.email_subscription)
  topic_arn = aws_sns_topic.ami_notifications.arn
  protocol  = "email"
  endpoint  = each.value # Replace with your email address
}

# Create IAM role for Lambda with SNS and EC2 permissions
resource "aws_iam_role" "lambda_iam_role" {
  name = "lambda-sns-ec2-full-access-role"

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

# Attach SNS full access policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_sns_full_access" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSNSFullAccess"
}

# Attach EC2 full access policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_ec2_full_access" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# Attach SNS publish policy to the Lambda role for specific SNS topic
resource "aws_iam_policy" "lambda_sns_publish_policy" {
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

# Attach the publish policy to the Lambda role
resource "aws_iam_role_policy_attachment" "lambda_sns_publish_policy_attach" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_sns_publish_policy.arn
}

# Lambda function to fetch AMI details and publish to SNS
resource "aws_lambda_function" "fetch_ami_and_notify" {
  filename         = archive_file.bottlerocketzip.output_path# Path to your packaged Lambda function code
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
  timeout      = 30
  memory_size  = 128
}

# Lambda permissions to allow it to be invoked by specific triggers
resource "aws_lambda_permission" "allow_sns_invoke" {
  statement_id  = "AllowSNSInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fetch_ami_and_notify.function_name
  principal     = "sns.amazonaws.com"
}

# SNS Topic policy to allow Lambda to publish to the topic
resource "aws_sns_topic_policy" "sns_topic_policy" {
  arn = aws_sns_topic.ami_notifications.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect: "Allow",
        Principal: {
          AWS: "*"
        },
        Action: "SNS:Publish",
        Resource: aws_sns_topic.ami_notifications.arn,
        Condition: {
          ArnEquals: {
            "AWS:SourceArn": aws_lambda_function.fetch_ami_and_notify.arn
          }
        }
      }
    ]
  })
}

# Additional IAM role policy to allow Lambda to use SSM for Bottlerocket AMI parameters
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

# Create EventBridge rule to trigger Lambda at a specific time (e.g., every day at 12:00 PM UTC)
resource "aws_cloudwatch_event_rule" "schedule_rule" {
  name                = "trigger-lambda-schedule"
  description         = "EventBridge rule to trigger Lambda at 12:00 PM UTC daily"
  schedule_expression = "cron(0 12 * * ? *)"  # Cron expression for every day at 12:00 PM UTC
}

# Set the Lambda function as the target for the EventBridge rule
resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.schedule_rule.name
  target_id = "LambdaFunction"  # Unique ID for the target
  arn       = aws_lambda_function.fetch_ami_and_notify.arn  # ARN of the Lambda function
}

# Grant permission to EventBridge to invoke the Lambda function
resource "aws_lambda_permission" "allow_eventbridge_invoke" {
  statement_id  = "AllowEventBridgeInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.fetch_ami_and_notify.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.schedule_rule.arn
}
