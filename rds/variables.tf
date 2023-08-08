########################################################################################################################
# General
########################################################################################################################

variable "db_name" {
  description = "Default database name"
  type        = string
}

variable "environment" {
  description = "Name of the environment to deploy the RDS to"
  type        = string
}

########################################################################################################################
# Tags
########################################################################################################################
########################################################################################################################
# Already supplied: Name, Environment, Region
########################################################################################################################

#todo better validation
variable "tags" {
  description = "User supplied tags"
  type        = map(any)
  default     = {}
}

#todo evaluate if needed
variable "purchase_type" {
  description = "Valid values are: On-Demand or Reserved. Reserved must only be used if the service is not going to change any of the following within the next 12 months"
  type        = string
  default     = "On-Demand"

  validation {
    condition     = contains(["On-Demand", "Reserved"], var.purchase_type)
    error_message = "Valid values for purchase_type are: On-Demand or Reserved."
  }
}

########################################################################################################################
# Engine
########################################################################################################################

# todo create list of supported instances for validation
variable "instance_class" {
  description = "Supported instance class for the RDS instance"
  type        = string
  default     = "db.t4g.micro"
}

variable "engine" {
  description = "RDS engine"
  type        = string
  default     = "postgres"
}

variable "engine_version" {
  description = "RDS engine version"
  type        = string
  default     = "5.7"
}

variable "parameter_group_family" {
  description = "Name of the DB parameter group family to associate"
  type        = string
  default     = "mysql5.7"
}

variable "parameter_group_parameters" {
  description = "List of the DB parameter group key values"
  type = list(object({
    name  = string
    value = string
  }))
  default = [
    { name = "general_log", value = 1 }
  ]
}

variable "option_group_name" {
  description = "Name of the DB option group to associate. Due to the complexity of a `aws_db_option_group` please define the resource and pass in the `name` if required."
  type        = string
  default     = null
}

########################################################################################################################
# Storage
########################################################################################################################

variable "allocated_storage" {
  description = "Starting storage allocation for the instance"
  type        = number
  default     = 8
}

variable "max_allocated_storage" {
  description = "Maximum size storage will be permitted to grow to"
  type        = number
  default     = null
}

variable "storage_type" {
  description = "Desired storage type. Supported types are standard, gp2, io1"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "gp2", "io1"], var.storage_type)
    error_message = "Valid storage types are: standard, gp2 or io1."
  }
}

variable "iops" {
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of \"io1\"."
  type        = number
  default     = null
}

########################################################################################################################
# Security
########################################################################################################################

variable "ca_cert_identifier" {
  description = "RDS CA for verifying database client certificate. Should be defaulted to the latest Amazon provided certificate unless maintaining backwards compatibility"
  type        = string
  default     = "rds-ca-2019"
}

variable "username" {
  description = "Default database username"
  type        = string
}

########################################################################################################################
# Disaster Recovery
########################################################################################################################

variable "backup_retention_period" {
  description = "The number of days automated backups should be retained (0-30)"
  type        = number
  default     = 30

  validation {
    condition = (
      var.backup_retention_period >= 0 && var.backup_retention_period <= 30
    )
    error_message = "The automated backup retention period should be between 0 and 30 days."
  }
}

variable "deletion_protection" {
  description = "Lock the resource so that extra friction is required to destroy the db instance"
  type        = bool
  default     = false
}

variable "skip_final_snapshot" {
  description = "Create a final snapshot when the database is deleted. The snapshot identifier will be as follows if false rds-{service}-{environment}-final-{random_non_colliding_id}"
  type        = bool
  default     = false
}

########################################################################################################################
# Maintenance
########################################################################################################################

variable "backup_window" {
  description = "Desired timeframe for automated snapshots to occur"
  type        = string
  default     = "01:00-02:00"
}

variable "maintenance_window" {
  description = "Desired timeframe for maintenance to occur"
  type        = string
  default     = "Sun:03:00-Sun:06:00"
}

variable "apply_immediately" {
  description = "Apply changes immediately or wait until the next maintenance_window (set to true to force change)"
  type        = bool
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Apply minor engine upgrades automatically. Set to false for minor engine upgrades to not automatically apply to the DB instance during the maintenance window."
  type        = bool
  default     = true
}

########################################################################################################################
# Networking
########################################################################################################################

variable "subnet_name" {
  description = "Target subnet name e.g. sn-{name}-{environment}-1a"
  type        = string
}

variable "subnet_group" {
  description = "Target subnet group name"
  type        = string
  default     = ""
}

variable "enable_random_port" {
  description = "Enable random port mapping"
  type        = bool
  default     = false
}

variable "network_type" {
  description = "The network type of the DB instance. Valid values: `IPV4`, `DUAL`."
  type        = string
  default     = null
}

variable "port" {
  description = "Desired port number"
  type        = number
  default     = 5432
}

variable "vpc_name" {
  description = "Name of the target VPC to deploy the RDS to"
  type        = string
}

########################################################################################################################
# Monitoring
########################################################################################################################

variable "enabled_cloudwatch_logs_exports" {
  description = "The list of desired CloudWatch logs you wish to export"
  type        = list(string)
  default     = ["audit", "error", "general", "slowquery"]
}

variable "monitoring_interval" {
  description = "Interval in which to collect metrics (1-5)"
  type        = number
  default     = 5

  validation {
    condition = (
      var.monitoring_interval >= 1 && var.monitoring_interval <= 5
    )
    error_message = "The monitoring_interval should be between 1 and 5."
  }
}

variable "performance_insights_retention" {
  description = "The number of days to retain insights data. Defaults to 7 as it's free up until that point."
  type        = number
  default     = 7
}

########################################################################################################################
# Oracle and MS SQL related options
########################################################################################################################

variable "character_set_name" {
  description = "The character set name to use for DB encoding in Oracle and Microsoft SQL instances (collation). This can't be changed."
  type        = string
  default     = null
}

variable "domain" {
  description = "The ID of the Directory Service Active Directory domain to create the instance in."
  type        = string
  default     = null
}

variable "domain_iam_role_name" {
  description = "The name of the IAM role to be used when making API calls to the Directory Service. Required if the `domain` is provided."
  type        = string
  default     = null
}

variable "license_model" {
  description = "License model information for this DB instance."
  type        = string
  default     = null
}

variable "nchar_character_set_name" {
  description = "The national character set is used in the NCHAR, NVARCHAR2, and NCLOB data types for Oracle instances. This can't be changed."
  type        = string
  default     = null
}

variable "timezone" {
  description = "Time zone of the DB instance. `timezone` is currently only supported by Microsoft SQL Server. The `timezone` can only be set on creation."
  type        = string
  default     = null
}