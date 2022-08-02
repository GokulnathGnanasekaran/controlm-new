module "vars" {
  source      = "../../../terraform/vars"
  environment = var.key
}

variable "key" {
  type        = string
  description = "environment"
}

variable "amzlinux2_id" {
  type        = string
  description = "amzlinux2_id"
}

variable "rhel7_id" {
  type        = string
  description = "rhel7_id"
}

locals {
  environment  = var.key
  ami_date     = formatdate("YYYY-MM-DD", timestamp())
  costcentre   = module.vars.costcentre
  live         = module.vars.live
  amzlinux2_id = var.amzlinux2_id
  rhel7_id     = var.rhel7_id
}
