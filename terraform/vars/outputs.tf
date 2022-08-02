output "project" {
  description = "Project Name"
  value       = local.project
}

output "common_tags" {
  description = "Common Tags"
  value = {
    email              = lookup(var.email, var.environment)
    costcentre         = lookup(var.costcentre, var.environment)
    live               = lookup(var.live, var.environment)
    environment        = var.environment
    dataRetention      = "greater-than-7-years"
    dataClassification = "confidential"
    builtby            = "Terraform"
    reponame           = "https://github.com/JSainsburyPLC/js-controlm-services"
  }
}

output "costcentre" {
  value = lookup(var.costcentre, var.environment)
}

output "live" {
  value = lookup(var.live, var.environment)
}

output "nonprod_tags" {
  description = "NonProd Tags"
  value = {
    servicename = local.project
  }
}

output "prod_tags" {
  description = "Prod Tags"
  value = {
    servicecatalogueid = "TBC"
  }
}

output "vpc_cidrblock" {
  description = "CIDR block range"
  value       = lookup(var.vpc_cidrblock, var.environment)
}

output "alt_env_name" {
  description = "Alternative environment name"
  value       = lookup(var.alt_env_name, var.environment)
}

output "env" {
  description = "Environment name"
  value = {
    dev  = "dev"
    prod = "prod"
  }
}

output "azs" {
  description = "Availability Zones"
  value = {
    azs = ["eu-west-1a", "eu-west-1b"]
  }
}

output "em_service_cname" {
  description = "EM service environment name"
  value       = lookup(var.em_service_cname, var.environment)
}

output "domain" {
  description = "Domain environment name"
  value       = lookup(var.domain, var.environment)
}

output "devops_cname" {
  description = "Route53 Public Zone name"
  value       = lookup(var.devops_cname, var.environment)
}

output "em_devops_cname" {
  description = "Route53 Public Zone WebAccess name"
  value       = lookup(var.em_devops_cname, var.environment)
}

output "em_devops_gui_cname" {
  description = "Route53 Public Zone GUI name"
  value       = lookup(var.em_devops_gui_cname, var.environment)
}

output "em_devops_db_service_cname" {
  description = "Route53 Public Zone Database name"
  value       = lookup(var.em_devops_db_service_cname, var.environment)
}

output "em_db_service_cname" {
  description = "Route53 Private Zone Database name"
  value       = lookup(var.em_db_service_cname, var.environment)
}

output "em_web_service_cname" {
  description = "Route53 Private Zone WebAccess name"
  value       = lookup(var.em_web_service_cname, var.environment)
}

output "proxy_service_cname" {
  description = "Route53 Private Zone Proxy name"
  value       = lookup(var.proxy_service_cname, var.environment)
}

output "proxy_loadbalancer" {
  description = "Proxy LB name"
  value = {
    name = "JS-SS-BLUECOAT-NLB-573f2c2495ebef7d.elb.eu-west-1.amazonaws.com"
    arn  = "arn:aws:elasticloadbalancing:eu-west-1:057726927330:loadbalancer/net/JS-SS-BLUECOAT-NLB/573f2c2495ebef7d"
  }
}

output "azones" {
  description = "Availability Zones, long and short"
  value = {
    azs_long  = "eu-west-1a, eu-west-1b"
    azs_short = "a, b"
  }
}

output "private_ip" {
  description = "Static IP's for EM servers"
  value = {
    dev  = "10.8.180.6, 10.8.180.36"
    prod = "10.8.23.151, 10.8.23.166"
  }
}

output "arc_private_ip" {
  description = "Static IP's for EM/ARC servers"
  value = {
    dev  = "10.8.180.21, 10.8.180.41"
    prod = "10.8.23.153, 10.8.23.181"
  }
}


output "ctmact" {
  description = "Primary/Secondary server names"
  value = {
    ctms = "Primary, Failover"
  }
}

output "ctms_env" {
  description = "Alternative environment name"
  value       = lookup(var.ctms_env, var.environment)
}

output "r53_ctms_env" {
  description = "Alternative environment name"
  value       = lookup(var.r53_ctms_env, var.environment)
}

output "datacenter" {
  description = "CTMS Datacenter name"
  value       = var.datacenter
}

output "ctms_port" {
  description = "Control-M/Server Server/Agent port"
  value       = lookup(var.ctms_port, var.datacenter)
}

output "bucket_name" {
  description = "Software bucket name"
  value       = "js-software-files"
}

output "github_owner" {
  description = "GitHub repo Owner"
  value       = "JSainsburyPLC"
}

output "infra_repo" {
  description = "GitHub repo Name"
  value       = "js-controlm-services"
}

output "common_ec2" {
  description = "General EC2 common object names"
  value = {
    # EC2 common variables
    win_ami_id         = "ami-0ba4d956f4577cf9c" # Windows Server 2016 - Full Base 2020
    lnx_instance_type  = "m5.xlarge"
    #rh_instance_type   = "t3.xlarge"
    rh_instance_type   = {
      dev = {
        ctmem  = "t3.xlarge"
        ctmarc = "t3.xlarge"
      }
      prod = {
        ctmem  = "m5.2xlarge"
        ctmarc = "t3.xlarge"
      }
    }
    ctms_instance_type = "m4.xlarge"
    win_instance_type  = "t3.micro"
    rds_dbuser         = "postgres"
    ctmem_username     = "emadmin"
    ctmarc_username    = "ctmarc"
    ctms_username      = "ctmsrv"
    keypair_ctms       = "js-controlm-ctms"
    keypair_pem_name   = "JS_CONTROLM_WINDOWS"
    keypair_ctmem      = "js-controlm-ctmem"
  }
}
