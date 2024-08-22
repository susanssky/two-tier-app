resource "aws_iam_role" "ssm" {
  name = "${local.project_name}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "attach" {
  count      = length(local.policy_arns)
  role       = aws_iam_role.ssm.name
  policy_arn = local.policy_arns[count.index]

}
