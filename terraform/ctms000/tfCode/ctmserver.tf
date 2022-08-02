data "template_file" "ctmsrv_script" {
  # Render the template once for each instance
  count    = 2
  template = file("../../templates//${local.userdata_filename}")
  vars = {
    efs_dns          = aws_efs_file_system.ctms_efs.dns_name
    software_efs_dns = local.software_efs_dns_name
    username         = module.vars.common_ec2["ctms_username"]
    inst_count       = count.index
    service_agt      = local.service_agt
    datacenter       = module.vars.datacenter
    ctms_env         = local.ctms_env
    ssm_endpoint     = local.ssm_endpoint
    r53_dc1          = local.r53_dc1
    r53_dc2          = local.r53_dc2
  }
}

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

resource "aws_instance" "ctmserver" {
  count                = 2
  depends_on           = [aws_efs_mount_target.ctms_efs_mount_1a, aws_efs_mount_target.ctms_efs_mount_1b]
  ami                  = data.aws_ami.rhel.id # module.vars.common_ec2["ctms_ami_id"]
  availability_zone    = element(split(", ", module.vars.azones["azs_long"]), count.index)
  instance_type        = module.vars.common_ec2["ctms_instance_type"]
  key_name             = module.vars.common_ec2["keypair_ctms"]
  iam_instance_profile = local.iam_instance_profile_name
  subnet_id = element(
    [local.subnet_1a_id, local.subnet_1b_id],
    count.index,
  )
  instance_initiated_shutdown_behavior = "terminate"
  tags = merge(
    {
      "Name"        = "JS-CONTROLM-Server_${module.vars.datacenter}-${element(split(", ", module.vars.ctmact["ctms"]), count.index)}"
      "Description" = "Control-M/Server Instance"
    },
    local.tags,
  )

  volume_tags = merge(
    {
      "Name"               = "Instance_Volume"
      "Description"        = "Control-M Server Volume"
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
    volume_size = "30"
    volume_type = "gp2"
    device_name = "/dev/sdb"
    encrypted   = true
  }

  # CTM File System Storage
  ebs_block_device {
    volume_size = "60"
    volume_type = "gp2"
    device_name = "/dev/sdf"
    encrypted   = true
  }

  # Security Group - JS_CONTROLM_SG
  vpc_security_group_ids = [
    local.ctm_sg_id,
  ]

  # User Data to mount EFS
  user_data = data.template_file.ctmsrv_script[count.index].rendered

  lifecycle {
    ignore_changes = [
      user_data,
      ami
    ]
  }

}
