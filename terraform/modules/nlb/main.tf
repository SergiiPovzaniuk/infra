resource "aws_eip" "this" {
  domain = "vpc"
  tags   = { Name = "${var.name}-nlb" }
}

resource "aws_lb" "this" {
  name               = substr(replace("${var.name}-nlb", "_", "-"), 0, 32)
  load_balancer_type = "network"
  ip_address_type    = "ipv4"

  subnet_mapping {
    subnet_id     = var.subnet_id
    allocation_id = aws_eip.this.id
  }

  tags = { Name = "${var.name}-nlb" }
}

resource "aws_lb_target_group" "http" {
  name     = substr(replace("${var.name}-http", "_", "-"), 0, 32)
  port     = 80
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "TCP"
    port     = "80"
  }

  tags = { Name = "${var.name}-http" }
}

resource "aws_lb_target_group" "https" {
  name     = substr(replace("${var.name}-https", "_", "-"), 0, 32)
  port     = 443
  protocol = "TCP"
  vpc_id   = var.vpc_id

  health_check {
    protocol = "TCP"
    port     = "443"
  }

  tags = { Name = "${var.name}-https" }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = 80
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.http.arn
  }
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.this.arn
  port              = 443
  protocol          = "TCP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.https.arn
  }
}

resource "aws_lb_target_group_attachment" "http" {
  for_each         = var.targets
  target_group_arn = aws_lb_target_group.http.arn
  target_id        = each.value
  port             = 80
}

resource "aws_lb_target_group_attachment" "https" {
  for_each         = var.targets
  target_group_arn = aws_lb_target_group.https.arn
  target_id        = each.value
  port             = 443
}
