data "aws_ssm_parameter" "ctmemdbpass" {
  name = "ctmemdbpass"
}

data "aws_ssm_parameter" "ctmempassword" {
  name = "ctmempassword"
}

data "aws_region" "current" {}

data "aws_ami" "rhel" {
  most_recent = true
  name_regex  = "^JS-CONTROLM-RHEL7-CIS-L1*"
  owners      = ["self"]

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "template_file" "userdata_script" {
  count    = 1
  template = file("../../templates/${local.userdata_filename}")

  # variables passed to the above template script
  vars = {
    environment        = local.environment
    software_efs_dns   = local.software_efs_dns_name
    username           = module.vars.common_ec2["ctmarc_username"]
    inst_count         = count.index
    efs_dns            = aws_efs_file_system.ctmarc_efs[count.index].dns_name
    ctmemdbpass        = data.aws_ssm_parameter.ctmemdbpass.value
    ctmempassword      = data.aws_ssm_parameter.ctmempassword.value
    region             = data.aws_region.current.name
    domain             = module.vars.domain
    ssm_endpoint       = local.ssm_endpoint
    ctmem_primary_dns  = local.ctmem_primary_dns
    ctmem_failover_dns = local.ctmem_failover_dns
    ctmem_user         = module.vars.common_ec2["ctmem_username"]
  }
}

resource "aws_instance" "ctmarc" {
  count                = 1
  ami                  = data.aws_ami.rhel.id
  availability_zone    = element(split(", ", module.vars.azones["azs_long"]), count.index)
  instance_type        = module.vars.common_ec2["rh_instance_type"][local.environment]["ctmarc"]
  key_name             = module.vars.common_ec2["keypair_ctmem"]
  iam_instance_profile = local.iam_instance_profile_name
  subnet_id = element(
    [local.subnet_1a_id, local.subnet_1b_id],
    count.index,
  )
  private_ip                           = element(split(", ", module.vars.arc_private_ip[local.environment]), count.index)
  instance_initiated_shutdown_behavior = "terminate"
  tags = merge(
    {
      "Name"        = "JS-CONTROLM-EM-Archive_${element(split(", ", module.vars.ctmact["ctms"]), count.index)}"
      "Description" = "Control-M/EM Archive Instance"
    },
    local.tags,
  )

  volume_tags = merge(
    {
      "Name"               = "Instance_Volume"
      "Description"        = "Control-M EM Volume"
      "dataRetention"      = "7-years"
      "dataClassification" = "confidential"
    },
    local.tags,
  )

  # Root Storage
  root_block_device {
    volume_size = "16"
    volume_type = "gp2"
    encrypted   = true
  }

  # Swap Storage
  ebs_block_device {
    volume_size = "12"
    volume_type = "gp2"
    device_name = "/dev/sdb"
    encrypted   = true
  }

  # CTMEM File System Storage
  #ebs_block_device {
  #  volume_size = "60"
  #  volume_type = "gp2"
  #  device_name = "/dev/sdf"
  #  encrypted   = true
  #}

  # Security Group - JS_CONTROLM_SG
  vpc_security_group_ids = [
    local.ctm_sg_id,
  ]

  # User Data to mount EFS
  user_data = data.template_file.userdata_script[count.index].rendered

  lifecycle {
    ignore_changes = [
      ami,
      user_data
    ]
  }
}
