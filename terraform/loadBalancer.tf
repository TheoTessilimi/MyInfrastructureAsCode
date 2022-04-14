#target group
resource "aws_lb_target_group" "test" {
  name        = "PrivateTargetInstance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.myVPC.id
  target_type = "instance"
  health_check {
    interval            = 30
    matcher             = "200,202"
    port                = 80
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }
}
#Attach target to lb
resource "aws_alb_target_group_attachment" "test" {
  target_group_arn = aws_lb_target_group.test.arn
  target_id        = aws_instance.private.id
  port             = 80
}

#LoadBalancer
resource "aws_lb" "test" {
  name               = "PrivateLB"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.myPublicSG.id]
  subnets            = [aws_subnet.myPublicSubnet.id, aws_subnet.myPrivateSubnet.id]

  enable_deletion_protection = false

  tags = {
    Environment = "production"
  }
}

#listenerLB
resource "aws_lb_listener" "example" {
  load_balancer_arn = aws_lb.test.arn
  port              = 80

  default_action {
    target_group_arn = aws_lb_target_group.test.arn
    type             = "forward"
  }
}
