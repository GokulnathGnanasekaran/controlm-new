resource "aws_efs_file_system" "ctmarc_efs" {
  count            = 1
  encrypted        = true
  performance_mode = "maxIO"
  throughput_mode  = "bursting"

  tags = merge(map("Name", "${module.vars.project}-em-archive_efs", "Description", "Control-M/Archive Elastic File System EFS", "dataRetention", "7-years", "dataClassification", "confidential"), local.tags)

}

resource "aws_efs_mount_target" "ctmarc1_efs_mount_1a" {
  file_system_id  = aws_efs_file_system.ctmarc_efs[0].id
  subnet_id       = local.subnet_1a_id
  security_groups = [local.ctm_sg_id]
}
resource "aws_efs_mount_target" "ctmarc1_efs_mount_1b" {
  file_system_id  = aws_efs_file_system.ctmarc_efs[0].id
  subnet_id       = local.subnet_1b_id
  security_groups = [local.ctm_sg_id]
}

#resource "aws_efs_mount_target" "ctmarc2_efs_mount_1a" {
#  file_system_id  = aws_efs_file_system.ctmarc_efs[1].id
#  subnet_id       = local.subnet_1a_id
#  security_groups = [local.ctm_sg_id]
#}
#resource "aws_efs_mount_target" "ctmarc2_efs_mount_1b" {
#  file_system_id  = aws_efs_file_system.ctmarc_efs[1].id
#  subnet_id       = local.subnet_1b_id
#  security_groups = [local.ctm_sg_id]
#}
