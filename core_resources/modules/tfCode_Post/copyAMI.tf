resource "null_resource" "stop_instances" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
        aws ec2 stop-instances --instance-ids ${local.amzlinux2_id} ${local.rhel7_id} --region eu-west-1
     EOT
  }
}

resource "time_sleep" "wait_post_stop" {
  depends_on      = [null_resource.stop_instances]
  create_duration = "180s"
}

resource "aws_ami_from_instance" "amzlinux2" {
  depends_on         = [time_sleep.wait_post_stop]
  name               = "JS-CONTROLM-AMZ_LINUX2-CIS-L1-${local.ami_date}"
  source_instance_id = local.amzlinux2_id
  tags = merge(
    {
      "Name"        = "JS-CONTROLM-AMZ_LINUX2-CIS-L1"
      "Description" = "Control-M AMZ_LINUX2 CIS Level1 AMI"
    },
    local.tags,
  )
}

resource "aws_ami_from_instance" "rhel7" {
  depends_on         = [time_sleep.wait_post_stop]
  name               = "JS-CONTROLM-RHEL7-CIS-L1-${local.ami_date}"
  source_instance_id = local.rhel7_id
  tags = merge(
    {
      "Name"        = "JS-CONTROLM-RHEL7-CIS-L1"
      "Description" = "Control-M RHEL7 CIS Level1 AMI"
    },
    local.tags,
  )
}

# Update AMI snapshot tags
resource "aws_ec2_tag" "complience_rhel" {
  for_each    = { "Name" : "AMI-Snapshot", "Description" : "Control-M AMI Snapshot", "costcentre" : local.costcentre, "live" : local.live, "environment" : local.environment }
  resource_id = aws_ami_from_instance.rhel7.root_snapshot_id
  key         = each.key
  value       = each.value
}

resource "aws_ec2_tag" "complience_amxl" {
  for_each    = { "Name" : "AMI-Snapshot", "Description" : "Control-M AMI Snapshot", "costcentre" : local.costcentre, "live" : local.live, "environment" : local.environment }
  resource_id = aws_ami_from_instance.amzlinux2.root_snapshot_id
  key         = each.key
  value       = each.value
}

resource "null_resource" "terminate_instances" {
  depends_on = [aws_ec2_tag.complience_rhel, aws_ec2_tag.complience_amxl]
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOT
        aws ec2 terminate-instances --instance-ids ${local.amzlinux2_id} ${local.rhel7_id} --region eu-west-1
     EOT
  }
}
