data "aws_vpc" "selected" {
  filter {
    name   = "cidr"
    values = [module.vars.vpc_cidrblock]
  }
}

data "aws_subnet" "ctm_sub_1a" {
  vpc_id            = data.aws_vpc.selected.id
  availability_zone = "eu-west-1a"
  filter {
    name   = "tag:tier"
    values = ["EM"]
  }
}

data "aws_subnet" "ctm_sub_1b" {
  vpc_id            = data.aws_vpc.selected.id
  availability_zone = "eu-west-1b"
  filter {
    name   = "tag:tier"
    values = ["EM"]
  }
}

data "aws_ami" "rhel" {
  most_recent = true
  name_regex  = "^JS-RHEL7-AMI-CIS-L1-*"
  owners      = ["057726927330"]
}

data "aws_ami" "amz_linux2" {
  most_recent = true
  name_regex  = "^JS-AMZN2-AMI-CIS-L1-*"
  owners      = ["057726927330"]
}

data "aws_iam_instance_profile" "profile" {
  name = "eu-west-1-js_instanceprofile_ctm"
}

data "aws_security_group" "security" {
  filter {
    name   = "tag:Name"
    values = ["${module.vars.project}-security-group"]
  }
}

data "template_file" "user_data" {
  # Render the template once for each instance
  template = file("../../modules/templates/ami_copy_user_data.sh")
}

resource "random_id" "server" {
  keepers = {
    # Generate a new id each time we switch to a new AMI id
    ami_id = data.aws_ami.rhel.id
  }
  byte_length = 8
}

resource "aws_instance" "ami_copy" {
  count                                = 2
  ami                                  = element(split(",", "${data.aws_ami.amz_linux2.id},${random_id.server.keepers.ami_id}"), count.index)
  availability_zone                    = element(split(", ", module.vars.azones["azs_long"]), count.index)
  instance_type                        = module.vars.common_ec2["ctms_instance_type"]
  key_name                             = module.vars.common_ec2["keypair_ctmem"]
  iam_instance_profile                 = data.aws_iam_instance_profile.profile.name
  subnet_id                            = element(split(",", "${data.aws_subnet.ctm_sub_1a.id},${data.aws_subnet.ctm_sub_1b.id}"), count.index)
  instance_initiated_shutdown_behavior = "terminate"
  tags = merge(
    {
      "Name"        = "JS-CONTROLM-COPY-AMI-${element(split(",", "AMZ-LINUX2,RHEL7"), count.index)}"
      "Description" = "Control-M Copy AMI Instance"
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

  # Security Group - JS_CONTROLM_SG
  vpc_security_group_ids = [
    data.aws_security_group.security.id
  ]

  # User Data to mount EFS
  user_data = data.template_file.user_data.rendered

  lifecycle {
    ignore_changes = [
      user_data,
      ami
    ]
  }

}
