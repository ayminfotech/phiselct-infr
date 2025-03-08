resource "aws_lb" "app_alb" {
  name               = "phi-select-${var.environment}-alb"
  load_balancer_type = "application"
  subnets            = aws_subnet.public[*].id
  security_groups    = [aws_security_group.alb_sg.id]
  tags = {
    Name        = "phi-select-${var.environment}-alb"
    Environment = var.environment
  }
}



resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.app_alb.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = data.aws_acm_certificate.wildcard_cert.arn
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.react_tg[0].arn  # For test environment
  }
}

resource "aws_lb_target_group_attachment" "react_tg_attachment" {
  count            = local.is_test ? 1 : 0
  target_group_arn = aws_lb_target_group.react_tg[0].arn
  target_id        = aws_instance.nginx_server.id
  port             = 80
}