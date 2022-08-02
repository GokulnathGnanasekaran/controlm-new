#
provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket         = "js-287296481067-statefiles"
    region         = "eu-west-1"
    key            = "terraform/dev/js-controlm-infra.tfstate"
    dynamodb_table = "js-287296481067-statefiles"
  }
  required_version = "0.12.31"
  required_providers {
    aws = {
      #source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

module "create_common_infra" {
  source = "../../common/tfCode"
  key    = local.environment
}

module "create_ctmem_infra" {
  source                    = "../../ctmem/tfCode"
  key                       = local.environment
  ctm_sg_id                 = module.create_common_infra.ctm_sg_id
  private_hosted_zone_id    = module.create_common_infra.private_hosted_zone_id
  public_hosted_zone_id     = module.create_common_infra.public_hosted_zone_id
  iam_instance_profile_name = module.create_common_infra.iam_instance_profile_name
  software_efs_dns_name     = module.create_common_infra.software_efs_dns_name
  ssm_endpoint              = module.create_common_infra.ssm_endpoint
}

module "create_ctmarc_infra" {
  source                    = "../../ctmarc/tfCode"
  key                       = local.environment
  ctm_sg_id                 = module.create_common_infra.ctm_sg_id
  private_hosted_zone_id    = module.create_common_infra.private_hosted_zone_id
  public_hosted_zone_id     = module.create_common_infra.public_hosted_zone_id
  iam_instance_profile_name = module.create_common_infra.iam_instance_profile_name
  software_efs_dns_name     = module.create_common_infra.software_efs_dns_name
  ssm_endpoint              = module.create_common_infra.ssm_endpoint
  ctmem_primary_dns         = module.create_ctmem_infra.primary_ctmem_dns
  ctmem_failover_dns        = module.create_ctmem_infra.failover_ctmem_dns
}

# Control-M/Server CTMS100 Datacentre
module "create_ctms100_infra" {
  source                    = "../../ctms000/tfCode"
  datacenter                = "ctms100"
  key                       = local.environment
  ctm_sg_id                 = module.create_common_infra.ctm_sg_id
  public_hosted_zone_id     = module.create_common_infra.public_hosted_zone_id
  iam_instance_profile_name = module.create_common_infra.iam_instance_profile_name
  software_efs_dns_name     = module.create_common_infra.software_efs_dns_name
  ssm_endpoint              = module.create_common_infra.ssm_endpoint
}

# Control-M/Server CTMS200 Datacentre
module "create_ctms200_infra" {
  source                    = "../../ctms000/tfCode"
  datacenter                = "ctms200"
  key                       = local.environment
  ctm_sg_id                 = module.create_common_infra.ctm_sg_id
  public_hosted_zone_id     = module.create_common_infra.public_hosted_zone_id
  iam_instance_profile_name = module.create_common_infra.iam_instance_profile_name
  software_efs_dns_name     = module.create_common_infra.software_efs_dns_name
  ssm_endpoint              = module.create_common_infra.ssm_endpoint
}

# Control-M/Server CTMS300 Datacentre
module "create_ctms300_infra" {
  source                    = "../../ctms000/tfCode"
  datacenter                = "ctms300"
  key                       = local.environment
  ctm_sg_id                 = module.create_common_infra.ctm_sg_id
  public_hosted_zone_id     = module.create_common_infra.public_hosted_zone_id
  iam_instance_profile_name = module.create_common_infra.iam_instance_profile_name
  software_efs_dns_name     = module.create_common_infra.software_efs_dns_name
  ssm_endpoint              = module.create_common_infra.ssm_endpoint
}

# Control-M/Server CTMS400 Datacentre
module "create_ctms400_infra" {
  source                    = "../../ctms000/tfCode"
  datacenter                = "ctms400"
  key                       = local.environment
  ctm_sg_id                 = module.create_common_infra.ctm_sg_id
  public_hosted_zone_id     = module.create_common_infra.public_hosted_zone_id
  iam_instance_profile_name = module.create_common_infra.iam_instance_profile_name
  software_efs_dns_name     = module.create_common_infra.software_efs_dns_name
  ssm_endpoint              = module.create_common_infra.ssm_endpoint
}

# Control-M/Server CTMS500 Datacentre
module "create_ctms500_infra" {
  source                    = "../../ctms000/tfCode"
  datacenter                = "ctms500"
  key                       = local.environment
  ctm_sg_id                 = module.create_common_infra.ctm_sg_id
  public_hosted_zone_id     = module.create_common_infra.public_hosted_zone_id
  iam_instance_profile_name = module.create_common_infra.iam_instance_profile_name
  software_efs_dns_name     = module.create_common_infra.software_efs_dns_name
  ssm_endpoint              = module.create_common_infra.ssm_endpoint
}

# Control-M/Server CTMS600 Datacentre
module "create_ctms600_infra" {
  source                    = "../../ctms000/tfCode"
  datacenter                = "ctms600"
  key                       = local.environment
  ctm_sg_id                 = module.create_common_infra.ctm_sg_id
  public_hosted_zone_id     = module.create_common_infra.public_hosted_zone_id
  iam_instance_profile_name = module.create_common_infra.iam_instance_profile_name
  software_efs_dns_name     = module.create_common_infra.software_efs_dns_name
  ssm_endpoint              = module.create_common_infra.ssm_endpoint
}

# Control-M/Server CTMS700 Datacentre
module "create_ctms700_infra" {
  source                    = "../../ctms000/tfCode"
  datacenter                = "ctms700"
  key                       = local.environment
  ctm_sg_id                 = module.create_common_infra.ctm_sg_id
  public_hosted_zone_id     = module.create_common_infra.public_hosted_zone_id
  iam_instance_profile_name = module.create_common_infra.iam_instance_profile_name
  software_efs_dns_name     = module.create_common_infra.software_efs_dns_name
  ssm_endpoint              = module.create_common_infra.ssm_endpoint
}
