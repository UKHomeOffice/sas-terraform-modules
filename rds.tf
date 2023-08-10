# kics-scan disable=88fd05e0-ac0e-43d2-ba6d-fc0ba60ae1a6,bca7cc4d-b3a4-4345-9461-eb69c68fcd26,e38a8e0a-b88b-4902-b3fe-b0fcb17d5c10

locals {
  subnet_group = var.subnet_group != "" ? var.subnet_group : aws_db_subnet_group.rds[0].name
}

resource "aws_db_instance" "rds" {
  ######################################################################################################################
  # Networking
  ######################################################################################################################
  port                   = var.enable_random_port ? random_integer.rds.result : var.port
  db_subnet_group_name   = local.subnet_group
  vpc_security_group_ids = [aws_security_group.rds.id]

  ######################################################################################################################
  # General
  ######################################################################################################################
  identifier = "rds-${var.service}-${var.environment}"
  db_name    = var.db_name

  ######################################################################################################################
  # Engine
  ######################################################################################################################
  instance_class       = var.instance_class
  engine               = var.engine
  engine_version       = var.engine_version
  parameter_group_name = aws_db_parameter_group.rds.name
  # Due to complexity of the aws_db_option_group I have decided against abstraction via dynamics
  option_group_name = var.option_group_name

  ######################################################################################################################
  # Storage
  ######################################################################################################################
  allocated_storage     = var.allocated_storage
  iops                  = var.iops
  max_allocated_storage = var.max_allocated_storage
  storage_type          = var.storage_type

  ######################################################################################################################
  # Security
  ######################################################################################################################
  ca_cert_identifier          = var.ca_cert_identifier
  username                    = var.username
  manage_master_user_password = true
  # password           = random_password.rds.result
  kms_key_id        = aws_kms_key.rds.arn
  storage_encrypted = true

  ######################################################################################################################
  # Disaster Recovery
  ######################################################################################################################
  multi_az                  = true
  backup_retention_period   = var.backup_retention_period
  deletion_protection       = var.deletion_protection
  delete_automated_backups  = false
  copy_tags_to_snapshot     = true
  skip_final_snapshot       = var.skip_final_snapshot
  final_snapshot_identifier = "rds-${var.service}-${var.environment}-final-${random_string.id.result}"

  ######################################################################################################################
  # Maintenance
  ######################################################################################################################
  backup_window               = var.backup_window
  maintenance_window          = var.maintenance_window
  allow_major_version_upgrade = false
  auto_minor_version_upgrade  = var.auto_minor_version_upgrade
  #checkov:skip=CKV_AWS_226:false value can be passed
  apply_immediately = var.apply_immediately

  ######################################################################################################################
  # Monitoring
  ######################################################################################################################
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  monitoring_interval             = var.monitoring_interval
  monitoring_role_arn             = aws_iam_role.rds.arn
  # On by default as free if data only retained for seven days, supports all engines and causes a race condition
  # if disable as both Terraform and RDS try to modify the KMS Key. Terraform always wins.
  # These params don't work with mysql engine
  # performance_insights_enabled          = false
  # performance_insights_kms_key_id       = aws_kms_key.performance_insights.arn
  # performance_insights_retention_period = var.performance_insights_retention

  ######################################################################################################################
  # Oracle and MS SQL related options
  ######################################################################################################################
  character_set_name       = var.character_set_name
  domain                   = var.domain
  domain_iam_role_name     = var.domain_iam_role_name
  license_model            = var.license_model
  nchar_character_set_name = var.nchar_character_set_name
  timezone                 = var.timezone

  tags = merge(
    { "Name" : "rds-${var.service}-${var.environment}" },
    var.tags
  )
}

resource "aws_db_subnet_group" "rds" {
  count = var.subnet_group == "" ? 1 : 0

  name        = "rds-sng-${var.service}-${var.environment}"
  description = "${var.service}-${var.environment} RDS subnet group"
  subnet_ids  = data.aws_subnets.rds_subnets.ids

  tags = merge(
    { "Name" : "rds-sng-${var.service}-${var.environment}" },
    var.tags
  )
}