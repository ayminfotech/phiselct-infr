resource "aws_lb_target_group" "gateway_tg" {
  count       = local.is_prod ? 1 : 0
  name        = "phi-select-${var.environment}-gateway-tg"
  port        = 8081
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/actuator/health"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Environment = var.environment,
    Project     = "phi-select"
  }
}

resource "aws_lb_target_group" "react_tg" {
  count       = local.is_test ? 1 : 0
  name        = "phi-select-${var.environment}-react-tg"
  port        = 80
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Environment = var.environment,
    Project     = "phi-select"
  }
}