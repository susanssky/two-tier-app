resource "aws_apigatewayv2_api" "backend" {
  name          = "${local.project_name}-http-api"
  protocol_type = "HTTP"
}

resource "aws_apigatewayv2_route" "example" {
  api_id    = aws_apigatewayv2_api.backend.id
  route_key = "ANY /{proxy+}"

  target = "integrations/${aws_apigatewayv2_integration.example.id}"
}

resource "aws_apigatewayv2_integration" "example" {
  api_id           = aws_apigatewayv2_api.backend.id
  integration_type = "HTTP_PROXY"

  integration_method = "ANY"
  integration_uri    = "http://${aws_lb.lb.dns_name}/{proxy}"
}
resource "aws_apigatewayv2_stage" "example" {
  api_id      = aws_apigatewayv2_api.backend.id
  auto_deploy = true
  name        = "v1"
}
