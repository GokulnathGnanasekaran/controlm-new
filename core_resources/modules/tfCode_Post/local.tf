locals {
  common_tags  = module.vars.common_tags
  prod_tags    = module.vars.prod_tags
  nonprod_tags = module.vars.nonprod_tags
  tags         = local.environment == "prod" ? merge(local.common_tags, local.prod_tags) : merge(local.common_tags, local.nonprod_tags)
}
