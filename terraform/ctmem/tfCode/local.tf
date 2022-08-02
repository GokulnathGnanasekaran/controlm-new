data "aws_vpc" "selected" {
  filter {
    name   = "cidr"
    values = [module.vars.vpc_cidrblock]
  }
}

#data "aws_route_tables" "selected" {
#  vpc_id = data.aws_vpc.selected.id
#}

data "aws_subnet_ids" "private_em" {
  vpc_id = data.aws_vpc.selected.id
  tags = {
    tier = "EM"
  }
}

data "aws_subnet" "em_sub_1a" {
  vpc_id            = data.aws_vpc.selected.id
  availability_zone = "eu-west-1a"
  filter {
    name   = "tag:tier"
    values = ["EM"]
  }
}

data "aws_subnet" "em_sub_1b" {
  vpc_id            = data.aws_vpc.selected.id
  availability_zone = "eu-west-1b"
  filter {
    name   = "tag:tier"
    values = ["EM"]
  }
}

locals {
  common_tags  = module.vars.common_tags
  prod_tags    = module.vars.prod_tags
  nonprod_tags = module.vars.nonprod_tags
  #routetable_ids    = data.aws_route_tables.selected.ids
  userdata_filename = "ctmem_sa_user_data.sh"
  vpc_id            = data.aws_vpc.selected.id
  subnet_ids        = data.aws_subnet_ids.private_em.ids
  subnet_1a_id      = data.aws_subnet.em_sub_1a.id
  subnet_1b_id      = data.aws_subnet.em_sub_1b.id
  #repo_infra_url    = "https://github.com/${module.vars.github_owner}/${module.vars.infra_repo}.git"
  tags = local.environment == "prod" ? merge(local.common_tags, local.prod_tags) : merge(local.common_tags, local.nonprod_tags)
}
