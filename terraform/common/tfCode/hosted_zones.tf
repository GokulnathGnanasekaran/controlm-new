resource "aws_route53_zone" "private" {
  name = "js.aws"

  # Private
  vpc {
    vpc_id = local.vpc_id
  }

  force_destroy = true
  comment       = "Private Hosted Zone for Control-M"
  tags = merge(
    {
      "Name"        = "js.aws"
      "description" = "Private Hosted Zone for Control-M"
    },
    local.tags,
  )
}

resource "aws_route53_zone" "public" {
  name = module.vars.devops_cname

  # Public
  force_destroy = true
  comment       = "Public Hosted Zone for Control-M"
  tags = merge(
    {
      "Name"        = module.vars.devops_cname
      "description" = "Public Hosted Zone for Control-M"
    },
    local.tags,
  )
}
