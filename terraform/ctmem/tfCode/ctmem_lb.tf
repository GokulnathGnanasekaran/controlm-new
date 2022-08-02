# Network Load-Balancer for Control-M Enterprise Manager
resource "aws_lb" "ctmem_nlb" {
  name               = "${module.vars.project}-ctmem-nlb"
  internal           = true
  load_balancer_type = "network"

  subnets = local.subnet_ids
  tags = merge(
    {
      "Name"        = "${module.vars.project}-ctmem-nlb"
      "Description" = "Control-M Enterprise Manager Server Network Load Balancer"
    },
    local.tags,
  )

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "ctmem_nlb_tg" {
  name     = "${module.vars.project}-ctmem-nlb-tg"
  port     = 13075
  protocol = "TCP"
  vpc_id   = local.vpc_id
  health_check {
    enabled  = true
    interval = 30
    port     = 13075
    protocol = "TCP"
  }
  tags = merge(
    {
      "Name"        = "${module.vars.project}-ctmem-nlb-tg"
      "Description" = "Control-M Enterprise Manager Server NLB Target Group"
    },
    local.tags,
  )
}

resource "aws_lb_listener" "ctmem_nlb_listener" {
  load_balancer_arn = aws_lb.ctmem_nlb.arn
  port              = "13075"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ctmem_nlb_tg.arn
  }
}

# Network Load-Balancer for Control-M Enterprise Manager Web Interface
resource "aws_lb" "ctmem_web_nlb" {
  name               = "${module.vars.project}-ctmem-web-nlb"
  internal           = true
  load_balancer_type = "network"

  subnets = local.subnet_ids
  tags = merge(
    {
      "Name"        = "${module.vars.project}-ctmem-web-nlb"
      "Description" = "Control-M Enterprise Manager Server Web Interface NLB"
    },
    local.tags,
  )

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "ctmem_web_nlb_tg" {
  name     = "${module.vars.project}-ctmem-web-nlb-tg"
  port     = "18080"
  protocol = "TCP"
  vpc_id   = local.vpc_id
  health_check {
    enabled  = true
    interval = 30
    port     = 18080
    protocol = "TCP"
  }
  tags = merge(
    {
      "Name"        = "${module.vars.project}-ctmem-web-nlb-tg"
      "Description" = "Control-M Enterprise Manager Server Web Interface NLB Target Group"
    },
    local.tags,
  )
}

resource "aws_lb_listener" "ctmem_web_nlb_listener" {
  load_balancer_arn = aws_lb.ctmem_web_nlb.arn
  port              = "18080"
  protocol          = "TCP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ctmem_web_nlb_tg.arn
  }
}
