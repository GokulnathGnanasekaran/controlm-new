#
provider "aws" {
  region = "eu-west-1"
}

terraform {
  backend "s3" {
    bucket         = "js-722459432465-statefiles"
    region         = "eu-west-1"
    key            = "terraform/prod/js-controlm-core_resource.tfstate"
    dynamodb_table = "js-722459432465-statefiles"
  }
  required_version = "0.12.31"
}

module "core_resources" {
  source = "../../modules/tfCode"
  key    = local.environment
}
