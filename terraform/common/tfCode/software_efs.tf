resource "aws_efs_file_system" "software_efs" {
  encrypted        = true
  performance_mode = "maxIO"
  throughput_mode  = "bursting"

  tags = merge(map("Name", "${module.vars.project}-application-software-efs", "Description", "Control-M CTM Software Elastic File System EFS", "dataRetention", "7-years", "dataClassification", "confidential"), local.tags)

  lifecycle_policy {
    transition_to_ia = "AFTER_30_DAYS"
  }
}


resource "aws_efs_mount_target" "software_efs_mount_1a" {
  file_system_id  = aws_efs_file_system.software_efs.id
  subnet_id       = local.ctm_subnet_1a_id
  security_groups = [aws_security_group.security.id]
}


resource "aws_efs_mount_target" "software_efs_mount_1b" {
  file_system_id  = aws_efs_file_system.software_efs.id
  subnet_id       = local.ctm_subnet_1b_id
  security_groups = [aws_security_group.security.id]
}
