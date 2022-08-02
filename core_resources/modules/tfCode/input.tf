module "vars" {
  source      = "../../../terraform/vars"
  environment = var.key
}

variable "key" {
  type        = string
  description = "environment"
}

locals {
  environment = var.key
  ami_date    = formatdate("YYYY-MM-DD", timestamp())
  costcentre  = module.vars.costcentre
  live        = module.vars.live
}
