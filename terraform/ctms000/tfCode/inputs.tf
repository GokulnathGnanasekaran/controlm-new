module "vars" {
  source      = "../../vars"
  environment = var.key
  datacenter  = var.datacenter
}

variable "key" {
  description = "Environment"
  type        = string
}

variable "ctm_sg_id" {
  description = "Security Group"
  type        = string
}

variable "datacenter" {
  description = "Control-M Datacenter"
  type        = string
}

variable "public_hosted_zone_id" {
  description = "Public Hosted Zone ID"
  type        = string
}

variable "iam_instance_profile_name" {
  description = "IAM Istance Profile"
  type        = string
}

variable "software_efs_dns_name" {
  description = "Software EFS name"
  type        = string
}

variable "ssm_endpoint" {
  description = "SSM Endpoint"
  type        = string
}

locals {
  environment               = var.key
  ctm_sg_id                 = var.ctm_sg_id
  public_hosted_zone_id     = var.public_hosted_zone_id
  iam_instance_profile_name = var.iam_instance_profile_name
  software_efs_dns_name     = var.software_efs_dns_name
  ssm_endpoint              = var.ssm_endpoint
  ctms_env                  = module.vars.ctms_env
  datacenter                = var.datacenter
  r53_dc1                   = join("", [substr(var.datacenter, 0, 6), "1.", module.vars.r53_ctms_env, ".js-devops.co.uk"])
  r53_dc2                   = join("", [substr(var.datacenter, 0, 6), "2.", module.vars.r53_ctms_env, ".js-devops.co.uk"])
  service_agt               = join("", ["a-", local.datacenter, "-", local.ctms_env, ".js.aws"])
}
