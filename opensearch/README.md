<!-- TF_DOCS_BLOCK START -->

AWS OpenSearch Module

---




## Documentation

The OpenSearch module is designed to work in the Common Pipeline for deployments to the EBSA platform.

### Basic Usage

Below is the bare minimum configuration required to create your new OpenSearch Domain.

This will deploy a Domain which consists of a single t3.small.search instance.

```terraform
module "opensearch" {
  source = "git::ssh://git@bitbucket.ipttools.info/cpt/cpt-terraform-opensearch.git?ref={tag}"

  environment       = var.environment
  region            = var.region
  service           = var.service
  tags              = local.all_tags
  vpc_id            = "vpc-xxx"
  account           = var.account
  domain_name       = "os-cpt-test" #Must be between 3 - 23 characters. We recommend (os|es)-{component}-{short environment name}.
  subnet_ids        = ["subnet-xxx", "subnet-xxx", "subnet-xxx"]
}
```

### Using Data Sources
```terraform
module "opensearch" {
  source = "git::ssh://git@bitbucket.ipttools.info/cpt/cpt-terraform-opensearch.git?ref={tag}"

  environment       = var.environment
  region            = var.region
  service           = var.service
  tags              = local.all_tags
  vpc_id            = data.aws_vpc.vpc.id
  account           = var.account
  domain_name       = "os-cpt-test" #Must be between 3 - 23 characters. We recommend (os|es)-{component}-{short environment name}.
  subnet_ids        = toset(data.aws_subnets.current.ids)
}
```
In data.tf:
```terraform
data "aws_vpc" "vpc" {
  filter {
    name   = "vpc-id"
    values = ["vpc-xxx"] #vpc for your environment
  }
}

data "aws_subnets" "current" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }

  tags = { 
    Name = "sn-prefix-${var.environment}-*" #change this value to reflect the naming convention of private subnets in your environment
  }
}
```
### Kubernetes Ingress

Though common, kubernetes ingress is not always required. To enable it follow the example below:

```terraform
module "opensearch" { 
    source = "git::ssh://git@bitbucket.ipttools.info/cpt/cpt-terraform-opensearch.git?ref={tag}"
    
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
  from_port         = 443
  to_port           = 443
  cidr_blocks       = [data.aws_vpc_peering_connection.kube.cidr_block]
  security_group_id = module.rds.security_group_id
  description       = "Allow ingress from kube env ${var.kubernetes_environment_group}"
}
```

---

## Vault Integration

By default, secrets (in this case the password) will be automatically stored in the relevant vault depending on the 
environment.  

To locate/create secrets please use the following example, changing the key of the key value of course:

```terraform
resource "vault_generic_secret" "some_resource_secret" {
  path = "secret/service/${var.service}/${var.environment}/some_secret"
  data_json = jsonencode({
    "some_key": "${random_password.password.result}"
  })
}
```

---

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account"></a> [account](#input\_account) | Target AWS account i.e. ops, np. | `string` | n/a | yes |
| <a name="input_dedicated_master_count"></a> [dedicated\_master\_count](#input\_dedicated\_master\_count) | Number of dedicated main nodes in the cluster.Should be greater than 1. | `number` | `null` | no |
| <a name="input_dedicated_master_enabled"></a> [dedicated\_master\_enabled](#input\_dedicated\_master\_enabled) | Determines if master nodes are deployed in the OpenSearch domain. | `bool` | `false` | no |
| <a name="input_dedicated_master_type"></a> [dedicated\_master\_type](#input\_dedicated\_master\_type) | Instance type of the dedicated main nodes in the cluster. | `string` | `"t3.small.search"` | no |
| <a name="input_domain_name"></a> [domain\_name](#input\_domain\_name) | The name for the OpenSearch domain. Must be greater than 3 characters and less than or equal to 28. Due to the restricted length of the domain name, teams will have to assign their own. We recommend (os\|es)-{component}-{short environment name}. It will be up to the end user to ensure this name is unique. | `string` | n/a | yes |
| <a name="input_ebs_enabled"></a> [ebs\_enabled](#input\_ebs\_enabled) | (Required) Whether EBS volumes are attached to data nodes in the | `bool` | `true` | no |
| <a name="input_ebs_iops"></a> [ebs\_iops](#input\_ebs\_iops) | Baseline input/output (I/O) performance of EBS volumes attached to data nodes. Applicable only for the GP3 and Provisioned IOPS EBS volume types. | `number` | `null` | no |
| <a name="input_ebs_throughput"></a> [ebs\_throughput](#input\_ebs\_throughput) | (Required if volume\_type is set to gp3) Specifies the throughput (in MiB/s) of the EBS volumes attached to data nodes. Applicable only for the gp3 volume type. | `number` | `null` | no |
| <a name="input_ebs_volume_size"></a> [ebs\_volume\_size](#input\_ebs\_volume\_size) | (Required if ebs\_enabled is true) Size of EBS volumes attached to data nodes (in GiB). | `number` | `10` | no |
| <a name="input_ebs_volume_type"></a> [ebs\_volume\_type](#input\_ebs\_volume\_type) | Type of EBS volumes attached to data nodes. | `string` | `"gp2"` | no |
| <a name="input_engine_version"></a> [engine\_version](#input\_engine\_version) | The version of OpenSearch that should be installed on the nodes that form the domain. | `string` | `"OpenSearch_2.5"` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Name of the environment to deploy the OpenSearch domain to. | `string` | n/a | yes |
| <a name="input_instance_count"></a> [instance\_count](#input\_instance\_count) | The number of nodes which should be deployed to the OpenSearch domain. | `number` | `1` | no |
| <a name="input_instance_type"></a> [instance\_type](#input\_instance\_type) | The type of node which should be deployed to form the OpenSearch domain. | `string` | `"t3.small.search"` | no |
| <a name="input_kms_deletion_window_in_days"></a> [kms\_deletion\_window\_in\_days](#input\_kms\_deletion\_window\_in\_days) | Duration in days after which the key is deleted after destruction of the resource, must be between 7 and 30 days. | `number` | `30` | no |
| <a name="input_log_retention_days"></a> [log\_retention\_days](#input\_log\_retention\_days) | The number of days that logs shipped from OpenSearch to CloudWatch should be retained for. | `number` | `365` | no |
| <a name="input_region"></a> [region](#input\_region) | The region where you wish to deploy the OpenSearch domain. | `string` | n/a | yes |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | List of additional VPC Security Group IDs to be applied to the OpenSearch domain endpoints. | `list(string)` | `[]` | no |
| <a name="input_service"></a> [service](#input\_service) | Name of the service using the naming standard {org}-{department}-{domain}-{service} | `string` | n/a | yes |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | List of VPC Subnet IDs for the OpenSearch domain endpoints to be created in. | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of user supplied tags. | `map(any)` | `{}` | no |
| <a name="input_tls_security_policy"></a> [tls\_security\_policy](#input\_tls\_security\_policy) | The TLS security policy to be enforced within the OpenSearch domain. | `string` | `"Policy-Min-TLS-1-2-2019-07"` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID of the target VPC to deploy the OpenSearch domain into. | `string` | n/a | yes |
## Outputs

| Name | Description |
|------|-------------|
| <a name="output_arn"></a> [arn](#output\_arn) | ARN of the domain. |
| <a name="output_availability_zones"></a> [availability\_zones](#output\_availability\_zones) | If the domain was created inside a VPC, the names of the availability zones the configured subnet\_ids were created inside. |
| <a name="output_domain_id"></a> [domain\_id](#output\_domain\_id) | Unique identifier for the domain. |
| <a name="output_domain_name"></a> [domain\_name](#output\_domain\_name) | Name of the opensearch domain. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | Domain-specific endpoint used to submit index, search, and data upload requests. |
| <a name="output_kibana_endpoint"></a> [kibana\_endpoint](#output\_kibana\_endpoint) | Domain-specific endpoint for kibana without https scheme. |
| <a name="output_master_password"></a> [master\_password](#output\_master\_password) | The randomly generated password for the OpenSearch domain. |
| <a name="output_master_username"></a> [master\_username](#output\_master\_username) | The randomly generated username for the OpenSearch domain. |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | The list of VPC Security Groups attached to the OpenSearch domain. |
| <a name="output_tags_all"></a> [tags\_all](#output\_tags\_all) | Map of tags assigned to the resource, including those inherited from the provider default\_tags configuration block. |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | If the domain was created inside a VPC, the ID of the VPC. |

---

## Integrations

As part of the Common Pipeline Terraform delivery, some services are provided by default and are available to integrate 
as part of your configuration with no additional setup. Below are a list of services and examples to help you quickly
begin to consume these services and reduce friction when applying best practice.

### Vault Integration

By default, secrets should be stored in the relevant vault by environment. Supplied modules in this project will 
automatically generate and store these for you and provide the path as an output to consume later in your configuration
or your service.

To store secrets in the vault, use the `vault_generic_secret` resource type and follow the following convention for the 
`path`:

```
"secret/service/${var.service}/${var.environment}/secret_name"
```

In place of `secret_name` should be your desired name.

Below is a more complete example of this:

```terraform
resource "vault_generic_secret" "some_resource_secret" {
  path = "secret/service/${var.service}/${var.environment}/rds"
  data_json = jsonencode({
    "password": "${random_password.password.result}"
  })
}
```

### Consul Integration

In addition to Vault, Consul is configured for use by default in the pipeline. You can store configurations in Consul by 
simply creating a Terraform resource as follows:

```terraform
resource "consul_keys" "rds_endpoint" {
  key {
    path  = "service/${var.service}/${var.environment}/rds_endpoint"
    value = module.rds.endpoint
  }
}

resource "consul_keys" "rds_port" {
  key {
    path  = "service/${var.service}/${var.environment}/rds_port"
    value = module.rds.port
  }
}
```

---

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

| File             | Level  | ID                                   | Description                                   | Reason                                                        |
|:-----------------|:-------|:-------------------------------------|:----------------------------------------------|:--------------------------------------------------------------|
| cloudwatch.tf    | INFO   | e38a8e0a-b88b-4902-b3fe-b0fcb17d5c10 | Resource Not Using Tags                       | False positive                                                |
| cloudwatch.tf    | LOW    | e592a0c5-5bdb-414c-9066-5dba7cdea370 | IAM Access Analyzer Not Enabled               | False positive                                                |
| cloudwatch.tf    | MEDIUM | ef0b316a-211e-42f1-888e-64efe172b755 | CloudWatch Without Retention Period Specified | False positive                                                |
| opensearch.tf | INFO   | e38a8e0a-b88b-4902-b3fe-b0fcb17d5c10 | Resource Not Using Tags                       | False positive                                                |
| opensearch.tf | MEDIUM | e979fcbc-df6c-422d-9458-c33d65e71c45 | OpenSearch Without Slow Logs               | Enabled by default.  Dynamic block used to allow disablement. |
| kms.tf           | INFO   | e38a8e0a-b88b-4902-b3fe-b0fcb17d5c10 | Resource Not Using Tags                       | False positive                                                |
| sg.tf            | INFO   | e38a8e0a-b88b-4902-b3fe-b0fcb17d5c10 | Resource Not Using Tags                       | False positive                                                |

## Checkov

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