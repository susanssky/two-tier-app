resource "aws_sns_topic" "ec2_status_updated" {
  name = "ec2-status-updated"
}

resource "aws_cloudwatch_event_rule" "console" {
  name = "eventbridge_rule"
  event_pattern = jsonencode({
    source = ["aws.ec2"],
    detail-type = [
      "EC2 Instance State-change Notification"
    ]
  })
}

resource "aws_cloudwatch_event_target" "sns" {
  rule      = aws_cloudwatch_event_rule.console.name
  target_id = "SendToSNS"
  arn       = aws_sns_topic.ec2_status_updated.arn
}

resource "aws_chatbot_slack_channel_configuration" "test" {
  configuration_name = "pushToSlack"
  iam_role_arn       = aws_iam_role.ssm.arn
  slack_channel_id   = var.slack_channel_id
  slack_team_id      = var.slack_workspace_id
  sns_topic_arns     = [aws_sns_topic.ec2_status_updated.arn]
}

resource "aws_sns_topic_policy" "default" {
  arn    = aws_sns_topic.ec2_status_updated.arn
  policy = data.aws_iam_policy_document.sns_topic_policy.json
}

data "aws_iam_policy_document" "sns_topic_policy" {
  statement {
    effect  = "Allow"
    actions = ["SNS:Publish"]

    principals {
      type        = "Service"
      identifiers = ["events.amazonaws.com"]
    }

    resources = [aws_sns_topic.ec2_status_updated.arn]
  }
}

