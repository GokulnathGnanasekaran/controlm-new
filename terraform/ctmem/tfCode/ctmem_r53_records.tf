resource "aws_route53_record" "ctmem_alias" {
  zone_id = local.private_hosted_zone_id
  name    = join("", ["a-ctmem-", module.vars.ctms_env, ".js.aws"])
  type    = "A"
  alias {
    name                   = aws_lb.ctmem_nlb.dns_name
    zone_id                = aws_lb.ctmem_nlb.zone_id
    evaluate_target_health = false
  }
}

# Route53 cname for public Web Interface
resource "aws_route53_record" "ctmem_public_web" {
  zone_id = local.public_hosted_zone_id
  name    = module.vars.em_devops_cname
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.ctmem_web_nlb.dns_name]
}

# Route53 cname for public GUI Interface
resource "aws_route53_record" "ctmem_public_gui" {
  zone_id = local.public_hosted_zone_id
  name    = module.vars.em_devops_gui_cname
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.ctmem_nlb.dns_name]
}

# Route53 cname for private ctmem gui
resource "aws_route53_record" "ctmem_gui" {
  zone_id = local.private_hosted_zone_id
  name    = module.vars.em_service_cname
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.ctmem_nlb.dns_name]
}

# Route53 cname for private ctmem web
resource "aws_route53_record" "ctmem_web" {
  zone_id = local.private_hosted_zone_id
  name    = module.vars.em_web_service_cname
  type    = "CNAME"
  ttl     = "300"
  records = [aws_lb.ctmem_web_nlb.dns_name]
}
