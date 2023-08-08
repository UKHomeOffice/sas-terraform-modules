# kics-scan disable=e38a8e0a-b88b-4902-b3fe-b0fcb17d5c10,e979fcbc-df6c-422d-9458-c33d65e71c45
#

resource "aws_opensearch_domain" "domain" {
  #checkov:skip=CKV_AWS_318:Configurable by teams
  #checkov:skip=CKV2_AWS_59:configurable by teams
  domain_name    = var.domain_name
  engine_version = var.engine_version

  dynamic "ebs_options" {
    for_each = length(regexall("^i3.*|^r6gd.*", var.instance_type)) > 0 ? [] : [1]
    content {
      ebs_enabled = true
      iops        = var.ebs_iops
      throughput  = var.ebs_throughput
      volume_size = var.ebs_volume_size
      volume_type = var.ebs_volume_type
    }
  }

  cluster_config {
    instance_type          = var.instance_type
    instance_count         = var.instance_count
    zone_awareness_enabled = var.instance_count > 1 ? true : false

    dedicated_master_count   = var.dedicated_master_count
    dedicated_master_enabled = var.dedicated_master_enabled
    dedicated_master_type    = var.dedicated_master_type

    dynamic "zone_awareness_config" {
      for_each = var.instance_count >= 3 ? [1] : []
      content {
        availability_zone_count = 3
      }
    }
  }

  vpc_options {
    subnet_ids = slice(
      data.aws_subnets.os_subnets.ids,
      0,
      var.instance_count > 3 ? 3 : var.instance_count
    )

    security_group_ids = concat(
      [aws_security_group.default.id],
      var.security_group_ids
    )
  }

  domain_endpoint_options {
    tls_security_policy = var.tls_security_policy
  }

  node_to_node_encryption {
    enabled = true
  }

  encrypt_at_rest {
    enabled    = true
    kms_key_id = aws_kms_key.opensearch.key_id
  }

  advanced_security_options {
    enabled                        = true
    internal_user_database_enabled = true
    master_user_options {
      master_user_name     = random_string.master_username.result
      master_user_password = random_password.master_password.result
    }
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.index_slow.arn
    log_type                 = "INDEX_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.search_slow.arn
    log_type                 = "SEARCH_SLOW_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.application.arn
    log_type                 = "ES_APPLICATION_LOGS"
  }

  log_publishing_options {
    cloudwatch_log_group_arn = aws_cloudwatch_log_group.audit.arn
    log_type                 = "AUDIT_LOGS"
    enabled                  = true
  }

  tags = merge(
    var.tags, {
      Name = var.domain_name
    }
  )

  depends_on = [
    aws_cloudwatch_log_resource_policy.opensearch_log_publishing_policy
  ]
}

resource "aws_opensearch_domain_policy" "main" {
  domain_name     = aws_opensearch_domain.domain.domain_name
  access_policies = data.aws_iam_policy_document.domain_access_policy.json
}

