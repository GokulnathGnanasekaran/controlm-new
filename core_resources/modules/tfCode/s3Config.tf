###########################################################################
# Create Software bucket
###########################################################################

resource "aws_s3_bucket" "config_bucket" {
  bucket = "${module.vars.project}-${local.environment}-config-files"
  acl    = "private"
  tags   = merge(map("Name", "${module.vars.project}-${local.environment}-config-files", "Description", "Control-M Config Bucket", "dataRetention", "7-years", "dataClassification", "confidential"), local.tags)

  lifecycle_rule {
    enabled = "true"
    noncurrent_version_expiration {
      days = 30
    }
  }
  versioning {
    enabled = "true"
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_public_access_block" "config_bucket" {
  bucket                  = aws_s3_bucket.config_bucket.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
