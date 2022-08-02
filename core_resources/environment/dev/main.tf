#
provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket         = "js-287296481067-statefiles"
    region         = "eu-west-1"
    key            = "terraform/dev/js-controlm-core_resource.tfstate"
    dynamodb_table = "js-287296481067-statefiles"
  }
  required_version = "0.12.31"
}

module "core_resources" {
  source = "../../modules/tfCode"
  key    = local.environment
}

module "post_core_resources" {
  source       = "../../modules/tfCode_Post"
  key          = local.environment
  amzlinux2_id = module.core_resources.amzlinux2_id
  rhel7_id     = module.core_resources.rhel7_id
}
