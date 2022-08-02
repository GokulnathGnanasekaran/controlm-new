data "aws_vpc" "selected" {
  filter {
    name   = "cidr"
    values = [module.vars.vpc_cidrblock]
  }
}

data "aws_subnet_ids" "private_em" {
  vpc_id = data.aws_vpc.selected.id
  tags = {
    tier = "EM"
  }
}

data "aws_route_tables" "selected" {
  vpc_id = data.aws_vpc.selected.id
}

data "aws_subnet" "ctm_sub_1a" {
  vpc_id            = data.aws_vpc.selected.id
  availability_zone = "eu-west-1a"
  filter {
    name   = "tag:tier"
    values = ["CTM"]
  }
}

data "aws_subnet" "ctm_sub_1b" {
  vpc_id            = data.aws_vpc.selected.id
  availability_zone = "eu-west-1b"
  filter {
    name   = "tag:tier"
    values = ["CTM"]
  }
}

locals {
  common_tags      = module.vars.common_tags
  prod_tags        = module.vars.prod_tags
  nonprod_tags     = module.vars.nonprod_tags
  vpc_id           = data.aws_vpc.selected.id
  routetable_ids   = data.aws_route_tables.selected.ids
  em_subnet_ids    = data.aws_subnet_ids.private_em.ids
  ctm_subnet_1a_id = data.aws_subnet.ctm_sub_1a.id
  ctm_subnet_1b_id = data.aws_subnet.ctm_sub_1b.id
  tags             = local.environment == "prod" ? merge(local.common_tags, local.prod_tags) : merge(local.common_tags, local.nonprod_tags)
}
