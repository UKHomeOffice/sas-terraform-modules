data "aws_iam_policy_document" "domain_access_policy" {
  statement {
    actions = [
      "es:AcceptInboundConnection",
      "es:AcceptInboundCrossClusterSearchConnection",
      "es:AddTags",
      "es:AssociatePackage",
      "es:AuthorizeVpcEndpointAccess",
      "es:CancelElasticsearchServiceSoftwareUpdate",
      "es:CancelServiceSoftwareUpdate",
      "es:CreateOutboundConnection",
      "es:CreateOutboundCrossClusterSearchConnection",
      "es:CreatePackage",
      "es:CreateOutboundCrossClusterSearchConnection",
      "es:DeleteInboundConnection",
      "es:DeleteInboundCrossClusterSearchConnection",
      "es:DeleteOutboundConnection",
      "es:DeleteOutboundCrossClusterSearchConnection",
      "es:DeletePackage",
      "es:Describe*",
      "es:ES*",
      "es:Get*",
      "es:List*",
      "es:Reject*",
      "es:RemoveTags",
      "es:Start*",
      "es:Update*",
      "es:Ugrade*",
    ]

    resources = [
      "arn:aws:es:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:domain/${var.domain_name}/*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}

data "aws_iam_policy_document" "opensearch_log_publishing_policy" {
  statement {
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:PutLogEventsBatch",
    ]

    resources = [
      "${aws_cloudwatch_log_group.application.arn}:*",
      "${aws_cloudwatch_log_group.audit.arn}:*",
      "${aws_cloudwatch_log_group.index_slow.arn}:*",
      "${aws_cloudwatch_log_group.search_slow.arn}:*"
    ]

    principals {
      identifiers = ["es.amazonaws.com"]
      type        = "Service"
    }
  }
}

data "aws_iam_policy_document" "kms_key_policy_logs" {
  #checkov:skip=CKV_AWS_111:policy restricts access to key it is attached to, adding the key arn creates a dependency cycle
  #checkov:skip=CKV_AWS_356:policy restricts access to key it is attached to, adding the key arn creates a dependency cycle
  #checkov:skip=CKV_AWS_109:full access is required otherwise the key is unmanageable
  statement {
    sid = "EnableManagementofKey"
    actions = [
      "kms:*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:Describe*"
    ]

    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.application_logs}",
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.audit_logs}",
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.index_slow_logs}",
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.search_slow_logs}"
      ]
    }

    resources = [
      "*"
    ]

    principals {
      type        = "Service"
      identifiers = ["logs.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "kms_key_policy_domain" {
  #checkov:skip=CKV_AWS_111:policy restricts access to key it is attached to, adding the key arn creates a dependency cycle
  #checkov:skip=CKV_AWS_356:policy restricts access to key it is attached to, adding the key arn creates a dependency cycle
  #checkov:skip=CKV_AWS_109:full access is required otherwise the key is unmanageable
  statement {
    #Required else the key is unmanageable
    sid = "EnableManagementofKey"
    actions = [
      "kms:*"
    ]

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }

    resources = [
      "*"
    ]
  }

  statement {
    actions = [
      "kms:Encrypt*",
      "kms:Decrypt*",
      "kms:ReEncrypt*",
      "kms:Describe*"
    ]

    condition {
      test     = "ArnEquals"
      variable = "kms:EncryptionContext:aws:logs:arn"
      values = [
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.application_logs}",
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.audit_logs}",
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.index_slow_logs}",
        "arn:aws:logs:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:log-group:${local.search_slow_logs}"
      ]
    }

    resources = [
      "*"
    ]

    principals {
      type        = "Service"
      identifiers = ["es.${data.aws_region.current.name}.amazonaws.com"]
    }
  }
}

data "aws_subnets" "os_subnets" {
  filter {
    name   = "tag:subnet_name"
    values = [var.subnet_name]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.sip_vpc.id]
  }
}

data "aws_vpc" "sip_vpc" {
  filter {
    name   = "tag:vpc_name"
    values = [var.vpc_name]
  }
}

data "aws_region" "current" {}
data "aws_caller_identity" "current" {}
data "aws_partition" "current" {}
data "aws_availability_zones" "available" {
  state = "available"
}

variable "service" {

}