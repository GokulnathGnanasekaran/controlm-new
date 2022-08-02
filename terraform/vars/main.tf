locals {
  project = "js-controlm"
}

variable "live" {
  description = "Signifies Prod or NonProd environments for Opex accountability"
  type        = map(any)
  default = {
    dev  = "no"
    prod = "no"
  }
}

variable "email" {
  description = "Team email"
  type        = map(any)
  default = {
    dev  = "ST_PSG_Scheduling@sainsburys.co.uk"
    prod = "ST_PSG_Scheduling@sainsburys.co.uk"
  }
}

variable "costcentre" {
  description = "Cost Centre Code"
  type        = map(any)
  default = {
    dev  = "PD7435"
    prod = "PD7435"
    #prod = "N2832"
  }
}

variable "alt_env_name" {
  description = "Alternative environment name"
  type        = map(any)
  default = {
    dev  = "Dev"
    prod = "Prod"
  }
}

variable "ctms_env" {
  description = "Alternative environment name"
  type        = map(any)
  default = {
    dev  = "d"
    prod = "p"
  }
}

variable "r53_ctms_env" {
  description = "Public Hosted Zone name"
  type        = map(any)
  default = {
    dev  = "controlm-nonprod"
    prod = "controlm-prod"
  }
}

variable "vpc_cidrblock" {
  description = "VPC CIDR range"
  type        = map(any)
  default = {
    dev  = "10.8.180.0/26"
    prod = "10.8.23.128/25"
  }
}

variable "em_service_cname" {
  description = "EM service environment name"
  type        = map(any)
  default = {
    dev  = "a-ctmgui-d.js.aws"
    prod = "a-ctmgui-p.js.aws"
  }
}

variable "domain" {
  description = "Domain environment name"
  type        = map(any)
  default = {
    dev  = "stbc2.jstest2.net"
    prod = "bc.jsplc.net"
  }
}

variable "devops_cname" {
  description = "Route53 Public Zone name"
  type        = map(any)
  default = {
    dev  = "controlm-nonprod.js-devops.co.uk"
    prod = "controlm-prod.js-devops.co.uk"
  }
}

variable "em_devops_cname" {
  description = "Route53 Public Zone WebAccess name"
  type        = map(any)
  default = {
    dev  = "webaccess.controlm-nonprod.js-devops.co.uk"
    prod = "webaccess.controlm-prod.js-devops.co.uk"
  }
}

variable "em_devops_gui_cname" {
  description = "Route53 Public Zone GUI name"
  type        = map(any)
  default = {
    dev  = "emgui.controlm-nonprod.js-devops.co.uk"
    prod = "emgui.controlm-prod.js-devops.co.uk"
  }
}

variable "em_devops_db_service_cname" {
  description = "Route53 Public Zone Database name"
  type        = map(any)
  default = {
    dev  = "emdb.controlm-nonprod.js-devops.co.uk"
    prod = "emdb.controlm-prod.js-devops.co.uk"
  }
}

variable "em_db_service_cname" {
  description = "Route53 Private Zone Database name"
  type        = map(any)
  default = {
    dev  = "a-ctmemdb-d.js.aws"
    prod = "a-ctmemdb-p.js.aws"
  }
}

variable "em_web_service_cname" {
  description = "Route53 Private Zone WebAccess name"
  type        = map(any)
  default = {
    dev  = "a-ctmemweb-d.js.aws"
    prod = "a-ctmemweb-p.js.aws"
  }
}

variable "proxy_service_cname" {
  description = "Route53 Private Zone Proxy name"
  type        = map(any)
  default = {
    dev  = "a-proxy-p.js.aws"
    prod = "a-proxy-p.js.aws"
  }
}

variable "ctms_port" {
  description = "Control-M/Server Server/Agent port"
  type        = map(any)
  default = {
    ctms100 = "10005"
    ctms200 = "11005"
    ctms300 = "12005"
    ctms400 = "13005"
    ctms500 = "14005"
    ctms600 = "15005"
    ctms700 = "16005"
    ctms800 = "17005"
  }
}
