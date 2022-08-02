resource "aws_efs_file_system" "ctmem_efs" {
  encrypted        = true
  performance_mode = "maxIO"
  throughput_mode  = "bursting"

  tags = merge(map("Name", "${module.vars.project}-ctmem_efs", "Description", "Control-M CTMEM Elastic File System EFS", "dataRetention", "7-years", "dataClassification", "confidential"), local.tags)

}

resource "aws_efs_mount_target" "ctmem_efs_mount_1a" {
  file_system_id  = aws_efs_file_system.ctmem_efs.id
  subnet_id       = local.subnet_1a_id
  security_groups = [local.ctm_sg_id]
}


resource "aws_efs_mount_target" "ctmem_efs_mount_1b" {
  file_system_id  = aws_efs_file_system.ctmem_efs.id
  subnet_id       = local.subnet_1b_id
  security_groups = [local.ctm_sg_id]
}
