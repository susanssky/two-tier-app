resource "aws_lb" "lb" {
  name               = "${local.project_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb.id] # http 80
  subnets            = [for id in aws_subnet.public[*].id : id]

  tags = {
    Name = "${local.project_name}-lb"
  }
}

resource "aws_lb_target_group" "lb-target-group" {
  name     = "4000-${local.project_name}"
  port     = 4000
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
}

resource "aws_lb_listener" "lb-listener" {
  load_balancer_arn = aws_lb.lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-target-group.arn
  }
}

