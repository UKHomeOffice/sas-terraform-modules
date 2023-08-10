output "address" {
  description = "The hostname of the RDS instance. See also endpoint and port."
  value       = aws_db_instance.rds.address
}

output "allocated_storage" {
  description = "The amount of allocated storage."
  value       = aws_db_instance.rds.allocated_storage
}

output "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed."
  value       = aws_db_instance.rds.allow_major_version_upgrade
}

output "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window."
  value       = aws_db_instance.rds.apply_immediately
}

output "arn" {
  description = "The ARN of the RDS instance."
  value       = aws_db_instance.rds.arn
}

output "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window."
  value       = aws_db_instance.rds.auto_minor_version_upgrade
}

output "availability_zone" {
  description = "The AZ for the RDS instance."
  value       = aws_db_instance.rds.availability_zone
}

output "backup_retention_period" {
  description = "The days to retain backups for."
  value       = aws_db_instance.rds.backup_retention_period
}

output "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled."
  value       = aws_db_instance.rds.backup_window
}

output "ca_cert_identifier" {
  description = "The identifier of the CA certificate for the DB instance."
  value       = aws_db_instance.rds.ca_cert_identifier
}

output "character_set_name" {
  description = "The character set name to use for DB encoding in Oracle and Microsoft SQL instances (collation)."
  value       = aws_db_instance.rds.character_set_name
}

output "copy_tags_to_snapshot" {
  description = "Copy all Instance tags to snapshots."
  value       = aws_db_instance.rds.copy_tags_to_snapshot
}

output "db_name" {
  description = "The name of the database to create when the DB instance is created."
  # provider 3.30 compat
  value = aws_db_instance.rds.db_name
}

output "db_subnet_group_name" {
  description = "Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group."
  value       = aws_db_instance.rds.db_subnet_group_name
}

output "delete_automated_backups" {
  description = "Specifies whether to remove automated backups immediately after the DB instance is deleted."
  value       = aws_db_instance.rds.delete_automated_backups
}

output "deletion_protection" {
  description = "If the DB instance should have deletion protection enabled."
  value       = aws_db_instance.rds.deletion_protection
}

output "domain" {
  description = "The ID of the Directory Service Active Directory domain to create the instance in."
  value       = aws_db_instance.rds.domain
}

output "domain_iam_role_name" {
  description = "The name of the IAM role to be used when making API calls to the Directory Service."
  value       = aws_db_instance.rds.domain_iam_role_name
}

output "enabled_cloudwatch_logs_exports" {
  description = "The log types enabled for exporting to CloudWatch logs."
  value       = aws_db_instance.rds.enabled_cloudwatch_logs_exports
}

output "endpoint" {
  description = "The connection endpoint in address:port format."
  value       = aws_db_instance.rds.endpoint
}

output "engine" {
  description = "The database engine."
  value       = aws_db_instance.rds.engine
}

output "engine_version" {
  description = "The database engine version."
  value       = aws_db_instance.rds.engine_version
}

output "engine_version_actual" {
  description = "The running version of the database."
  value       = aws_db_instance.rds.engine_version_actual
}

output "environment" {
  description = "The EBSA environment your RDS is deployed to."
  value       = var.environment
}

output "final_snapshot_identifier" {
  description = "The name of your final DB snapshot when this DB instance is deleted."
  value       = aws_db_instance.rds.final_snapshot_identifier
}

output "hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)."
  value       = aws_db_instance.rds.hosted_zone_id
}

output "iam_database_authentication_enabled" {
  description = "Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled."
  value       = aws_db_instance.rds.iam_database_authentication_enabled
}

output "id" {
  description = "The RDS instance ID."
  value       = aws_db_instance.rds.id
}

output "identifier" {
  description = "The name of the RDS instance."
  value       = aws_db_instance.rds.identifier
}

output "identifier_prefix" {
  description = "Creates a unique identifier beginning with the specified prefix."
  value       = aws_db_instance.rds.identifier_prefix
}

output "instance_class" {
  description = "The instance type of the RDS instance."
  value       = aws_db_instance.rds.instance_class
}

output "iops" {
  description = "The amount of provisioned IOPS."
  value       = aws_db_instance.rds.iops
}

output "kms_key_id" {
  description = "The ARN for the KMS encryption key."
  value       = aws_db_instance.rds.kms_key_id
}

output "latest_restorable_time" {
  description = "The latest time, in UTC RFC3339 format, to which a database can be restored with point-in-time restore."
  value       = aws_db_instance.rds.latest_restorable_time
}

output "maintenance_window" {
  description = "The instance maintenance window."
  value       = aws_db_instance.rds.maintenance_window
}

output "max_allocated_storage" {
  description = "The upper limit to which Amazon RDS can automatically scale the storage of the DB instance."
  value       = aws_db_instance.rds.max_allocated_storage
}

output "monitoring_role_arn" {
  description = "The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs."
  value       = aws_db_instance.rds.monitoring_role_arn
}

output "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ."
  value       = aws_db_instance.rds.multi_az
}

output "nchar_character_set_name" {
  description = "The national character set is used in the NCHAR, NVARCHAR2, and NCLOB data types for Oracle instances."
  value       = aws_db_instance.rds.nchar_character_set_name
}

output "option_group_name" {
  description = "Name of the DB option group to associate."
  value       = aws_db_instance.rds.option_group_name
}

output "parameter_group_name" {
  description = "Name of the DB parameter group to associate."
  value       = aws_db_instance.rds.parameter_group_name
}

output "performance_insights_enabled" {
  description = "Specifies whether Performance Insights are enabled."
  value       = aws_db_instance.rds.performance_insights_enabled
}

output "performance_insights_kms_key_id" {
  description = "The ARN for the KMS key to encrypt Performance Insights data."
  value       = aws_db_instance.rds.performance_insights_kms_key_id
}

output "performance_insights_retention_period" {
  description = "The amount of time in days to retain Performance Insights data."
  value       = aws_db_instance.rds.performance_insights_retention_period
}

output "port" {
  description = "The port on which the DB accepts connections."
  value       = aws_db_instance.rds.port
}

output "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible."
  value       = aws_db_instance.rds.publicly_accessible
}

output "replica_mode" {
  description = "Specifies whether the replica is in either mounted or open-read-only mode."
  value       = aws_db_instance.rds.replica_mode
}

output "replicate_source_db" {
  description = "Specifies that this resource is a Replicate database, and to use this value as the source database."
  value       = aws_db_instance.rds.replicate_source_db
}

output "resource_id" {
  description = "The RDS Resource ID of this instance."
  value       = aws_db_instance.rds.resource_id
}

output "restore_to_point_in_time" {
  description = "A configuration block for restoring a DB instance to an arbitrary point in time."
  value       = aws_db_instance.rds.restore_to_point_in_time
}

output "s3_import" {
  description = "Restore from a Percona Xtrabackup in S3."
  value       = aws_db_instance.rds.s3_import
}

output "security_group_id" {
  description = "The security group id of the primary security group created with the RDS."
  value       = aws_security_group.rds.id
}

output "security_group_names" {
  description = "List of DB Security Groups."
  value       = aws_db_instance.rds.vpc_security_group_ids
}

output "service" {
  description = "The EBSA designated name for your service."
  value       = var.service
}

output "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted."
  value       = aws_db_instance.rds.skip_final_snapshot
}

output "snapshot_identifier" {
  description = "Snapshot to restore the database from."
  value       = aws_db_instance.rds.snapshot_identifier
}

output "status" {
  description = "The RDS instance status."
  value       = aws_db_instance.rds.status
}

output "storage_encrypted" {
  description = "Specifies whether the DB instance is encrypted."
  value       = aws_db_instance.rds.storage_encrypted
}

output "storage_type" {
  description = "One of standard (magnetic), gp2 (general purpose SSD), or io1 (provisioned IOPS SSD)."
  value       = aws_db_instance.rds.storage_type
}

output "tags" {
  description = "A map of tags to assign to the resource."
  value       = aws_db_instance.rds.tags
}

output "tags_all" {
  description = "A map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_db_instance.rds.tags_all
}

output "timezone" {
  description = "Time zone of the DB instance. timezone is currently only supported by Microsoft SQL Server. "
  value       = aws_db_instance.rds.timezone
}

output "username" {
  description = "Username for the master DB user."
  value       = aws_db_instance.rds.username
}

output "vpc_security_group_ids" {
  description = "List of VPC security groups."
  value       = aws_db_instance.rds.vpc_security_group_ids
}
