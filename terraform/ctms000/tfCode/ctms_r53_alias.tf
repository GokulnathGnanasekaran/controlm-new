# Route53 cname for public ctms
resource "aws_route53_record" "public_ctms1" {
  zone_id = local.public_hosted_zone_id
  name    = local.r53_dc1
  type    = "A"
  ttl     = "300"
  records = [aws_instance.ctmserver[0].private_ip]
}

resource "aws_route53_record" "public_ctms2" {
  zone_id = local.public_hosted_zone_id
  name    = local.r53_dc2
  type    = "A"
  ttl     = "300"
  records = [aws_instance.ctmserver[1].private_ip]
}
