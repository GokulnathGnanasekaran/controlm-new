module "vars" {
  source      = "../../vars"
  environment = var.key
}

variable "key" {
  type        = string
  description = "environment"
}

variable "egress_cidr_manual" {
  default = {
    dev  = ["10.0.0.0/8"]
    prod = ["10.0.0.0/8", "192.168.18.0/24"]
  }
}

variable "ingress_cidr_manual" {
  default = {
    dev  = ["10.0.0.0/8", "192.168.0.0/16"]
    prod = ["10.0.0.0/8", "192.168.18.0/24"]
  }
}

locals {
  environment = var.key
}
