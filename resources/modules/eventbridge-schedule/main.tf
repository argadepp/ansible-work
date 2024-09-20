resource "aws_cloudwatch_event_rule" "every_day" {
  name                = var.rulename
  schedule_expression = "cron(${var.cron-value})"  
  tags = merge({Name= var.rulename},var.tags)
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.every_day.name
  target_id = var.targetid
  arn       = var.lambdaarn

}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.every_day.arn
}