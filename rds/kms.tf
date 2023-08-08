# kics-scan disable=7ebc9038-0bde-479a-acc4-6ed7b6758899,e592a0c5-5bdb-414c-9066-5dba7cdea370,e38a8e0a-b88b-4902-b3fe-b0fcb17d5c10

resource "aws_kms_key" "rds" {
  deletion_window_in_days = var.backup_retention_period
  enable_key_rotation     = true
  description             = "Key material for service RDS ${var.service}"

  tags = merge(
    { "Name" : "kms-rds-${var.service}-${var.environment}" },
    var.tags
  )
}

resource "aws_kms_alias" "rds" {
  target_key_id = aws_kms_key.rds.id
  name          = "alias/kms-${var.service}-encryptionkey-${var.environment}"
}

resource "aws_kms_key" "performance_insights" {
  deletion_window_in_days = var.performance_insights_retention
  enable_key_rotation     = true
  description             = "Key material for service RDS ${var.service} performance insights"

  tags = merge(
    { "Name" : "kms-rds-${var.service}-${var.environment}-performance-insights" },
    var.tags
  )
}

resource "aws_kms_alias" "performance_insights" {
  target_key_id = aws_kms_key.performance_insights.id
  name          = "alias/kms-${var.service}-encryptionkey-${var.environment}-performance-insights"
}