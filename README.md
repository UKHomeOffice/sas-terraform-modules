<!-- TF_DOCS_BLOCK START -->
# AWS RDS Module
---



## Documentation 

The RDS module is designed to work in the Common Pipeline for deployments to the EBSA platform. By default, the module 
is configured to create a Postgres RDS instance for ease of use as it is the most common but other engines can be 
configured. 

### Basic Usage

Below is bare minimum configuration required to create your new RDS Instance. 

Please note that the default value for `parameter_group_parameters` is the minimum required to successfully deploy your 
RDS and must be supplied by you if overridden. If a different engine is required, please implement best practice for 
that engine and validate using [Checkov](https://www.checkov.io/).

```terraform
module "rds" {
    source = "git::ssh://git@bitbucket.ipttools.info/cpt/cpt-terraform-rds.git?ref={tag}"
    
    account     = var.account
    region      = var.region
    service     = var.service
    environment = var.environment
    
    db_name            = var.db_name
    enable_random_port = var.enable_random_port
    subnet_name        = var.subnet_name
    username           = var.username
    vpc_id             = data.aws_vpc.current.id
    apply_immediately  = var.apply_immediately
    
    allocated_storage = 20
    storage_type      = "gp2"
    
    # local.all_tags provided by pipeline
    tags = local.all_tags
}
```

### Parameter Group Configuration

To enable custom parameter groups, all you need to do is pass in a `list` of `object` types with `name` and `value` attributes like so:
```terraform
module "rds" { 
    source = "git::ssh://git@bitbucket.ipttools.info/cpt/cpt-terraform-rds.git?ref={tag}"
  
    # ...
    
    # the following are the minimum parameters required to pass pipeline scanning
    parameter_group_family = "postgres14"
    parameter_group_parameters = [
      { name = "log_statement", value = "ddl" },
      { name = "log_min_duration_statement", value = "1" }
    ]
}
```

### Kubernetes Ingress

Though common, kubernetes ingress is not always required. To enable it follow the example below:

```terraform
module "rds" { 
    source = "git::ssh://git@bitbucket.ipttools.info/cpt/cpt-terraform-rds.git?ref={tag}"
    
    # ...
}

data "aws_vpc_peering_connection" "kube" {
  filter {
    name = "tag:Name"
    values = [
      "peer-${var.environment_group}-${var.aws_account}-${var.region}-${var.kubernetes_environment_group}-${var.kubernetes_account}-${var.region}",
      "peer-${var.kubernetes_environment_group}-${var.kubernetes_account}-${var.region}-${var.environment_group}-${var.aws_account}-${var.region}"
    ]
  }
}

resource "aws_security_group_rule" "kube_ingress" {
  type              = "ingress"
  protocol          = "tcp"
  from_port         = module.rds.port
  to_port           = module.rds.port
  cidr_blocks       = [data.aws_vpc_peering_connection.kube.cidr_block]
  security_group_id = module.rds.security_group_id
  description       = "Allow ingress from kube env ${var.kubernetes_environment_group}"
}
```

### Storing Secrets

By default, secrets should be stored in the relevant vault by environment. To store secrets in the vault, use the 
`vault_generic_secret` resource type and follow the following convention for the `path`:

```
"secret/service/${var.service}/${var.environment}/secret_name"
```

In place of `secret_name` should be your desired name. Below is a more complete example of this:

```terraform
resource "vault_generic_secret" "rds_password" {
  path = "secret/service/${var.service}/${var.environment}/rds"
  data_json = jsonencode({
    "password" : module.rds.password
  })
}
```
---
## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account"></a> [account](#input\_account) | Target AWS account i.e. ops, np | `string` | n/a | yes |
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Starting storage allocation for the instance | `number` | `8` | no |
| <a name="input_apply_immediately"></a> [apply\_immediately](#input\_apply\_immediately) | Apply changes immediately or wait until the next maintenance\_window (set to true to force change) | `bool` | `false` | no |
| <a name="input_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#input\_auto\_minor\_version\_upgrade) | Apply minor engine upgrades automatically. Set to false for minor engine upgrades to not automatically apply to the DB instance during the maintenance window. | `bool` | `true` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | The number of days automated backups should be retained (0-30) | `number` | `30` | no |
| <a name="input_backup_window"></a> [backup\_window](#input\_backup\_window) | Desired timeframe for automated snapshots to occur | `string` | `"01:00-02:00"` | no |
| <a name="input_ca_cert_identifier"></a> [ca\_cert\_identifier](#input\_ca\_cert\_identifier) | RDS CA for verifying database client certificate. Should be defaulted to the latest Amazon provided certificate unless maintaining backwards compatibility | `string` | `"rds-ca-2019"` | no |
| <a name="input_character_set_name"></a> [character\_set\_name](#input\_character\_set\_name) | The character set name to use for DB encoding in Oracle and Microsoft SQL instances (collation). This can't be changed. | `string` | `null` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Default database name | `string` | n/a | yes |
| <a name="input_deletion_protection"></a> [deletion\_protection](#input\_deletion\_protection) | Lock the resource so that extra friction is required to destroy the db instance | `bool` | `false` | no |
| <a name="input_domain"></a> [domain](#input\_domain) | The ID of the Directory Service Active Directory domain to create the instance in. | `string` | `null` | no |
| <a name="input_domain_iam_role_name"></a> [domain\_iam\_role\_name](#input\_domain\_iam\_role\_name) | The name of the IAM role to be used when making API calls to the Directory Service. Required if the `domain` is provided. | `string` | `null` | no |
| <a name="input_enable_random_port"></a> [enable\_random\_port](#input\_enable\_random\_port) | Enable random port mapping | `bool` | `false` | no |
| <a name="input_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#input\_enabled\_cloudwatch\_logs\_exports) | The list of desired CloudWatch logs you wish to export | `list(string)` | <pre>[<br>  "postgresql",<br>  "upgrade"<br>]</pre> | no |
| <a name="input_engine"></a> [engine](#input\_engine) | RDS engine | `string` | `"postgres"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | RDS engine version | `string` | `"14.4"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment to deploy the RDS to | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Supported instance class for the RDS instance | `string` | `"db.t4g.micro"` | no |
| <a name="input_iops"></a> [iops](#input\_iops) | The amount of provisioned IOPS. Setting this implies a storage\_type of "io1". | `number` | `null` | no |
| <a name="input_license_model"></a> [license\_model](#input\_license\_model) | License model information for this DB instance. | `string` | `null` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Desired timeframe for maintenance to occur | `string` | `"Sun:03:00-Sun:06:00"` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Maximum size storage will be permitted to grow to | `number` | `null` | no |
| <a name="input_monitoring_interval"></a> [monitoring\_interval](#input\_monitoring\_interval) | Interval in which to collect metrics (1-5) | `number` | `5` | no |
| <a name="input_nchar_character_set_name"></a> [nchar\_character\_set\_name](#input\_nchar\_character\_set\_name) | The national character set is used in the NCHAR, NVARCHAR2, and NCLOB data types for Oracle instances. This can't be changed. | `string` | `null` | no |
| <a name="input_network_type"></a> [network\_type](#input\_network\_type) | The network type of the DB instance. Valid values: `IPV4`, `DUAL`. | `string` | `null` | no |
| <a name="input_option_group_name"></a> [option\_group\_name](#input\_option\_group\_name) | Name of the DB option group to associate. Due to the complexity of a `aws_db_option_group` please define the resource and pass in the `name` if required. | `string` | `null` | no |
| <a name="input_parameter_group_family"></a> [parameter\_group\_family](#input\_parameter\_group\_family) | Name of the DB parameter group family to associate | `string` | `"postgres14"` | no |
| <a name="input_parameter_group_parameters"></a> [parameter\_group\_parameters](#input\_parameter\_group\_parameters) | List of the DB parameter group key values | <pre>list(object({<br>    name  = string<br>    value = string<br>  }))</pre> | <pre>[<br>  {<br>    "name": "log_statement",<br>    "value": "ddl"<br>  },<br>  {<br>    "name": "log_min_duration_statement",<br>    "value": "1"<br>  }<br>]</pre> | no |
| <a name="input_performance_insights_retention"></a> [performance\_insights\_retention](#input\_performance\_insights\_retention) | The number of days to retain insights data. Defaults to 7 as it's free up until that point. | `number` | `7` | no |
| <a name="input_port"></a> [port](#input\_port) | Desired port number | `number` | `5432` | no |
| <a name="input_purchase_type"></a> [purchase\_type](#input\_purchase\_type) | Valid values are: On-Demand or Reserved. Reserved must only be used if the service is not going to change any of the following within the next 12 months | `string` | `"On-Demand"` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where you wish to deploy the RDS instance i.e. ew1 | `string` | n/a | yes |
| <a name="input_service"></a> [service](#input\_service) | Name of the service using the naming standard {org}-{department}-{domain}-{service} | `string` | n/a | yes |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Create a final snapshot when the database is deleted. The snapshot identifier will be as follows if false rds-{service}-{environment}-final-{random\_non\_colliding\_id} | `bool` | `false` | no |
| <a name="input_storage_type"></a> [storage\_type](#input\_storage\_type) | Desired storage type. Supported types are standard, gp2, io1 | `string` | `"standard"` | no |
| <a name="input_subnet_group"></a> [subnet\_group](#input\_subnet\_group) | Target subnet group name | `string` | `""` | no |
| <a name="input_subnet_name"></a> [subnet\_name](#input\_subnet\_name) | Target subnet name e.g. sn-{name}-{environment}-1a | `string` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | User supplied tags | `map(any)` | `{}` | no |
| <a name="input_timezone"></a> [timezone](#input\_timezone) | Time zone of the DB instance. `timezone` is currently only supported by Microsoft SQL Server. The `timezone` can only be set on creation. | `string` | `null` | no |
| <a name="input_username"></a> [username](#input\_username) | Default database username | `string` | n/a | yes |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the target VPC to deploy the RDS to | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_address"></a> [address](#output\_address) | The hostname of the RDS instance. See also endpoint and port. |
| <a name="output_allocated_storage"></a> [allocated\_storage](#output\_allocated\_storage) | The amount of allocated storage. |
| <a name="output_allow_major_version_upgrade"></a> [allow\_major\_version\_upgrade](#output\_allow\_major\_version\_upgrade) | Indicates that major version upgrades are allowed. |
| <a name="output_apply_immediately"></a> [apply\_immediately](#output\_apply\_immediately) | Specifies whether any database modifications are applied immediately, or during the next maintenance window. |
| <a name="output_arn"></a> [arn](#output\_arn) | The ARN of the RDS instance. |
| <a name="output_auto_minor_version_upgrade"></a> [auto\_minor\_version\_upgrade](#output\_auto\_minor\_version\_upgrade) | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window. |
| <a name="output_availability_zone"></a> [availability\_zone](#output\_availability\_zone) | The AZ for the RDS instance. |
| <a name="output_backup_retention_period"></a> [backup\_retention\_period](#output\_backup\_retention\_period) | The days to retain backups for. |
| <a name="output_backup_window"></a> [backup\_window](#output\_backup\_window) | The daily time range (in UTC) during which automated backups are created if they are enabled. |
| <a name="output_ca_cert_identifier"></a> [ca\_cert\_identifier](#output\_ca\_cert\_identifier) | The identifier of the CA certificate for the DB instance. |
| <a name="output_character_set_name"></a> [character\_set\_name](#output\_character\_set\_name) | The character set name to use for DB encoding in Oracle and Microsoft SQL instances (collation). |
| <a name="output_copy_tags_to_snapshot"></a> [copy\_tags\_to\_snapshot](#output\_copy\_tags\_to\_snapshot) | Copy all Instance tags to snapshots. |
| <a name="output_db_name"></a> [db\_name](#output\_db\_name) | The name of the database to create when the DB instance is created. |
| <a name="output_db_subnet_group_name"></a> [db\_subnet\_group\_name](#output\_db\_subnet\_group\_name) | Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. |
| <a name="output_delete_automated_backups"></a> [delete\_automated\_backups](#output\_delete\_automated\_backups) | Specifies whether to remove automated backups immediately after the DB instance is deleted. |
| <a name="output_deletion_protection"></a> [deletion\_protection](#output\_deletion\_protection) | If the DB instance should have deletion protection enabled. |
| <a name="output_domain"></a> [domain](#output\_domain) | The ID of the Directory Service Active Directory domain to create the instance in. |
| <a name="output_domain_iam_role_name"></a> [domain\_iam\_role\_name](#output\_domain\_iam\_role\_name) | The name of the IAM role to be used when making API calls to the Directory Service. |
| <a name="output_enabled_cloudwatch_logs_exports"></a> [enabled\_cloudwatch\_logs\_exports](#output\_enabled\_cloudwatch\_logs\_exports) | The log types enabled for exporting to CloudWatch logs. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | The connection endpoint in address:port format. |
| <a name="output_engine"></a> [engine](#output\_engine) | The database engine. |
| <a name="output_engine_version"></a> [engine\_version](#output\_engine\_version) | The database engine version. |
| <a name="output_engine_version_actual"></a> [engine\_version\_actual](#output\_engine\_version\_actual) | The running version of the database. |
| <a name="output_environment"></a> [environment](#output\_environment) | The EBSA environment your RDS is deployed to. |
| <a name="output_final_snapshot_identifier"></a> [final\_snapshot\_identifier](#output\_final\_snapshot\_identifier) | The name of your final DB snapshot when this DB instance is deleted. |
| <a name="output_hosted_zone_id"></a> [hosted\_zone\_id](#output\_hosted\_zone\_id) | The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record). |
| <a name="output_iam_database_authentication_enabled"></a> [iam\_database\_authentication\_enabled](#output\_iam\_database\_authentication\_enabled) | Specifies whether or mappings of AWS Identity and Access Management (IAM) accounts to database accounts is enabled. |
| <a name="output_id"></a> [id](#output\_id) | The RDS instance ID. |
| <a name="output_identifier"></a> [identifier](#output\_identifier) | The name of the RDS instance. |
| <a name="output_identifier_prefix"></a> [identifier\_prefix](#output\_identifier\_prefix) | Creates a unique identifier beginning with the specified prefix. |
| <a name="output_instance_class"></a> [instance\_class](#output\_instance\_class) | The instance type of the RDS instance. |
| <a name="output_iops"></a> [iops](#output\_iops) | The amount of provisioned IOPS. |
| <a name="output_kms_key_id"></a> [kms\_key\_id](#output\_kms\_key\_id) | The ARN for the KMS encryption key. |
| <a name="output_latest_restorable_time"></a> [latest\_restorable\_time](#output\_latest\_restorable\_time) | The latest time, in UTC RFC3339 format, to which a database can be restored with point-in-time restore. |
| <a name="output_maintenance_window"></a> [maintenance\_window](#output\_maintenance\_window) | The instance maintenance window. |
| <a name="output_max_allocated_storage"></a> [max\_allocated\_storage](#output\_max\_allocated\_storage) | The upper limit to which Amazon RDS can automatically scale the storage of the DB instance. |
| <a name="output_monitoring_role_arn"></a> [monitoring\_role\_arn](#output\_monitoring\_role\_arn) | The ARN for the IAM role that permits RDS to send enhanced monitoring metrics to CloudWatch Logs. |
| <a name="output_multi_az"></a> [multi\_az](#output\_multi\_az) | Specifies if the RDS instance is multi-AZ. |
| <a name="output_nchar_character_set_name"></a> [nchar\_character\_set\_name](#output\_nchar\_character\_set\_name) | The national character set is used in the NCHAR, NVARCHAR2, and NCLOB data types for Oracle instances. |
| <a name="output_option_group_name"></a> [option\_group\_name](#output\_option\_group\_name) | Name of the DB option group to associate. |
| <a name="output_parameter_group_name"></a> [parameter\_group\_name](#output\_parameter\_group\_name) | Name of the DB parameter group to associate. |
| <a name="output_password"></a> [password](#output\_password) | The randomly generated password for the RDS instance. |
| <a name="output_performance_insights_enabled"></a> [performance\_insights\_enabled](#output\_performance\_insights\_enabled) | Specifies whether Performance Insights are enabled. |
| <a name="output_performance_insights_kms_key_id"></a> [performance\_insights\_kms\_key\_id](#output\_performance\_insights\_kms\_key\_id) | The ARN for the KMS key to encrypt Performance Insights data. |
| <a name="output_performance_insights_retention_period"></a> [performance\_insights\_retention\_period](#output\_performance\_insights\_retention\_period) | The amount of time in days to retain Performance Insights data. |
| <a name="output_port"></a> [port](#output\_port) | The port on which the DB accepts connections. |
| <a name="output_publicly_accessible"></a> [publicly\_accessible](#output\_publicly\_accessible) | Bool to control if instance is publicly accessible. |
| <a name="output_replica_mode"></a> [replica\_mode](#output\_replica\_mode) | Specifies whether the replica is in either mounted or open-read-only mode. |
| <a name="output_replicate_source_db"></a> [replicate\_source\_db](#output\_replicate\_source\_db) | Specifies that this resource is a Replicate database, and to use this value as the source database. |
| <a name="output_resource_id"></a> [resource\_id](#output\_resource\_id) | The RDS Resource ID of this instance. |
| <a name="output_restore_to_point_in_time"></a> [restore\_to\_point\_in\_time](#output\_restore\_to\_point\_in\_time) | A configuration block for restoring a DB instance to an arbitrary point in time. |
| <a name="output_s3_import"></a> [s3\_import](#output\_s3\_import) | Restore from a Percona Xtrabackup in S3. |
| <a name="output_security_group_id"></a> [security\_group\_id](#output\_security\_group\_id) | The security group id of the primary security group created with the RDS. |
| <a name="output_security_group_names"></a> [security\_group\_names](#output\_security\_group\_names) | List of DB Security Groups. |
| <a name="output_service"></a> [service](#output\_service) | The EBSA designated name for your service. |
| <a name="output_skip_final_snapshot"></a> [skip\_final\_snapshot](#output\_skip\_final\_snapshot) | Determines whether a final DB snapshot is created before the DB instance is deleted. |
| <a name="output_snapshot_identifier"></a> [snapshot\_identifier](#output\_snapshot\_identifier) | Snapshot to restore the database from. |
| <a name="output_status"></a> [status](#output\_status) | The RDS instance status. |
| <a name="output_storage_encrypted"></a> [storage\_encrypted](#output\_storage\_encrypted) | Specifies whether the DB instance is encrypted. |
| <a name="output_storage_type"></a> [storage\_type](#output\_storage\_type) | One of standard (magnetic), gp2 (general purpose SSD), or io1 (provisioned IOPS SSD). |
| <a name="output_tags"></a> [tags](#output\_tags) | A map of tags to assign to the resource. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | A map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_timezone"></a> [timezone](#output\_timezone) | Time zone of the DB instance. timezone is currently only supported by Microsoft SQL Server. |
| <a name="output_username"></a> [username](#output\_username) | Username for the master DB user. |
| <a name="output_vpc_security_group_ids"></a> [vpc\_security\_group\_ids](#output\_vpc\_security\_group\_ids) | List of VPC security groups. |
---
## Contributing

PR's are always welcome, but before you begin please install the pre-commit hook using the guide below:

```bash
chmod +x setup
./setup
```

## Code, Compliance and Scanning

During the module development and consumption cycle, layered tool usage is required to ensure security and best practice
are followed.

### Scanning

In order to successfully deploy infrastructure via the pipeline, all configuration must be clear of any
<span style="color:yellow">LOW</span>, <span style="color:orange">MEDIUM</span> or
<span style="color:red">HIGH</span> warnings from both [KICS](https://kics.io/) and [Checkov](https://www.checkov.io/)
unless an exception is agreed.

#### KICS

[KICS](https://kics.io/) is a broad spectrum IaC vulnerability scanning tool. It has the capability to scan and detect
non-competencies and security issues during the configuration development process in multiple tool and platform
combinations.   

Basic usage is as follows:

```bash
kics scan --type terraform --path . -o kics --cloud-provider aws
```

Once the output is printed to stdout or file, use the results to inform any remediation required.

#### Checkov

[Checkov](https://www.checkov.io/) is a Terraform centric, linting and vulnerability scanning tool. It also has the
capability to scan and detect non-competencies and security issues during the configuration development process.

Basic usage is as follows:

```bash
checkov -d .
```

Once the output is printed to stdout or file, use the results to inform any remediation required.

### Exceptions and Exclusions

From time to time, it may be required to exclude a detected non-compliance in your configuration. To do this you simply
add a comment to the file/line following the tools required syntax.

Examples are as follows:

#### KICS

```terraform
# kics-scan disable=88fd05e0-ac0e-43d2-ba6d-fc0ba60ae1a6,bca7cc4d-b3a4-4345-9461-eb69c68fcd26

resource "aws_db_instance" "rds" {
}
```

#### Checkov

```terraform
resource "aws_kms_key" "rds" {
  deletion_window_in_days = var.backup_retention_period
  #checkov:skip=CKV_AWS_7:Client requested no rotation of key material and has supplied the required wavers  
  enable_key_rotation     = false
  description             = "Key material for service ${var.service}"
}
```

#### Logging Exceptions

Depending on the severity of the detected issue, it may be required to acquire a security exception. Please see Support
at the bottom of the page for more information.

When the situation arises that you are required to exclude a rule due to policy, false positive, etc. Please add an
entry to docs/security/exclusions.md in the following format.

### KICS

| File    | Level | ID                                   | Description                     | Reason                                                      |
|:--------|:------|:-------------------------------------|:--------------------------------|:------------------------------------------------------------|
| file.tf | LOW   | bca7cc4d-b3a4-4345-9461-eb69c68fcd26 | RDS Using Default Port          | Not an enforced policy/requirement.                         |

### Checkov

| File    | ID        | Description                        | Reason                                                                            |
|:--------|:----------|:-----------------------------------|:----------------------------------------------------------------------------------|
| file.tf | CKV\_AWS\_7 | Ensure AWS CMK rotation is enabled | Client requested no rotation of key material and has supplied the required wavers |
---
## Scan Rule Exclusions

The following is the current list of rule exclusions, by tool with the reason.

### KICS

| File         | Level | ID                                   | Description                     | Reason                                                      |
|:-------------|:------|:-------------------------------------|:--------------------------------|:------------------------------------------------------------|
| rds.tf       | LOW   | bca7cc4d-b3a4-4345-9461-eb69c68fcd26 | RDS Using Default Port          | Not an enforced policy/requirement.                         |
| rds.tf       | HIGH  | 88fd05e0-ac0e-43d2-ba6d-fc0ba60ae1a6 | IAM Database Auth Not Enabled   | Not an enforced policy/requirement. Can be enabled by user. |
| consul.tf    | LOW   | e592a0c5-5bdb-414c-9066-5dba7cdea370 | IAM Access Analyzer Not Enabled | False positive.                                             |
| iam.tf       | LOW   | e592a0c5-5bdb-414c-9066-5dba7cdea370 | IAM Access Analyzer Not Enabled | False positive.                                             |
| iam.tf       | INFO  | e38a8e0a-b88b-4902-b3fe-b0fcb17d5c10 | Resource Not Using Tags         | Unable to add due to IAM policy restrictions.               |
| kms.tf       | HIGH  | 7ebc9038-0bde-479a-acc4-6ed7b6758899 | KMS Key With Vulnerable Policy  | Not currently enforced. Wil investigate further to improve. |
| kms.tf       | LOW   | e592a0c5-5bdb-414c-9066-5dba7cdea370 | IAM Access Analyzer Not Enabled | False positive.                                             |
| rds.tf       | INFO  | e38a8e0a-b88b-4902-b3fe-b0fcb17d5c10 | Resource Not Using Tags         | False positive.                                             |
| resources.tf | INFO  | e38a8e0a-b88b-4902-b3fe-b0fcb17d5c10 | Resource Not Using Tags         | False positive.                                             |
| sg.tf        | INFO  | e38a8e0a-b88b-4902-b3fe-b0fcb17d5c10 | Resource Not Using Tags         | False positive.                                             |
| vault.tf     | HIGH  | 487f4be7-3fd9-4506-a07a-eae252180c08 | Generic Password                | False positive.                                             |

### Checkov

| File | ID  | Description | Reason |
|:-----|:----|:------------|:-------|
|      |     |             |        |
---
## Support

For further assistance, queries and questions please direct them to the various channels in the #ukim-tech Slack:

* #cpt-support: For support with the Common Pipeline, module and feature requests.
* #terraform-anonymous: For general Terraform questions and queries.
* #platform-ebsa-mbtp-support: For environment, hosting or platform support.
<!-- TF_DOCS_BLOCK END -->