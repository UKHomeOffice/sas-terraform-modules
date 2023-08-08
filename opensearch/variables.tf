########################################################################################################################
# General
########################################################################################################################

variable "tags" {
  description = "A map of user supplied tags."
  type        = map(any)
  default     = {}
}

variable "environment" {
  description = "Name of the environment to deploy the RDS to"
  type        = string
}

########################################################################################################################
# OpenSearch
########################################################################################################################
variable "domain_name" {
  type        = string
  description = "The name for the OpenSearch domain. Must be greater than 3 characters and less than or equal to 28. Due to the restricted length of the domain name, teams will have to assign their own. We recommend (os|es)-{component}-{short environment name}. It will be up to the end user to ensure this name is unique."

  validation {
    condition = (
      length(var.domain_name) >= 3 && length(var.domain_name) <= 28
    )
    error_message = "The domain_name should be between 3 and 28 characters long."
  }

  validation {
    condition = (
      can(regex("^([a-zA-Z0-9-\\-]+)$", var.domain_name))
    )
    error_message = "The domain_name should contain a-z, A-Z, 0-9 and - only."
  }
}

variable "dedicated_master_count" {
  description = "Number of dedicated main nodes in the cluster.Should be greater than 1."
  default     = null
  type        = number
}

variable "dedicated_master_enabled" {
  type        = bool
  description = "Determines if master nodes are deployed in the OpenSearch domain."
  default     = false
}

variable "dedicated_master_type" {
  type        = string
  description = "Instance type of the dedicated main nodes in the cluster."
  default     = "t3.small.search"
}

variable "instance_count" {
  type        = number
  description = "The number of nodes which should be deployed to the OpenSearch domain."
  default     = 1
}

variable "instance_type" {
  type        = string
  description = "The type of node which should be deployed to form the OpenSearch domain."
  default     = "t3.small.search"
}

variable "kms_deletion_window_in_days" {
  type        = number
  description = "Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days."
  default     = 30

  validation {
    condition = (
      var.kms_deletion_window_in_days >= 7 && var.kms_deletion_window_in_days <= 30
    )
    error_message = "The kms_deletion_window_in_days should be between 7 and 30."
  }
}

variable "log_retention_days" {
  type        = number
  description = "The number of days that logs shipped from OpenSearch to CloudWatch should be retained for."
  default     = 365

  validation {
    condition = (
      var.log_retention_days >= 365
    )
    error_message = "The log_retention_days should be between greater than or equal to 365."
  }
}

variable "tls_security_policy" {
  description = "The TLS security policy to be enforced within the OpenSearch domain."
  type        = string
  default     = "Policy-Min-TLS-1-2-2019-07"
}

variable "engine_version" {
  type        = string
  description = "The version of OpenSearch that should be installed on the nodes that form the domain."
  default     = "Elasticsearch_7.10"
}

variable "ebs_enabled" {
  type        = bool
  description = "(Required) Whether EBS volumes are attached to data nodes in the"
  default     = true
}

variable "ebs_iops" {
  type        = number
  description = "Baseline input/output (I/O) performance of EBS volumes attached to data nodes. Applicable only for the GP3 and Provisioned IOPS EBS volume types."
  default     = null
}

variable "ebs_throughput" {
  type        = number
  description = "(Required if volume_type is set to gp3) Specifies the throughput (in MiB/s) of the EBS volumes attached to data nodes. Applicable only for the gp3 volume type."
  default     = null
}

variable "ebs_volume_size" {
  type        = number
  description = "(Required if ebs_enabled is true) Size of EBS volumes attached to data nodes (in GiB)."
  default     = 10
}

variable "ebs_volume_type" {
  type        = string
  description = "Type of EBS volumes attached to data nodes."
  default     = "gp2"
}

########################################################################################################################
# Networking
########################################################################################################################

variable "security_group_ids" {
  type        = list(string)
  description = "List of additional VPC Security Group IDs to be applied to the OpenSearch domain endpoints."
  default     = []
}

variable "vpc_name" {
  description = "Name of the target VPC to deploy the RDS to"
  type        = string
}

variable "subnet_name" {
  description = "Target subnet name e.g. sn-{name}-{environment}-1a"
  type        = string
}