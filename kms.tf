# kics-scan disable=e38a8e0a-b88b-4902-b3fe-b0fcb17d5c10

resource "aws_kms_key" "logs" {
  description             = "Key material for CloudWatch Log Groups belonging to the service ${var.domain_name}"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_key_policy_logs.json
  tags = merge(
    var.tags, {
      Name = "kms-cw-${var.domain_name}"
    }
  )
}

resource "aws_kms_alias" "logs" {
  name          = "alias/kms-cw-${var.domain_name}"
  target_key_id = aws_kms_key.logs.key_id
}

resource "aws_kms_key" "opensearch" {
  description             = "Key material for OpenSearch service ${var.domain_name}"
  deletion_window_in_days = var.kms_deletion_window_in_days
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.kms_key_policy_domain.json
  tags = merge(
    var.tags, {
      Name = "kms-os-${var.domain_name}"
    }
  )
}

resource "aws_kms_alias" "opensearch" {
  name          = "alias/kms-os-${var.domain_name}"
  target_key_id = aws_kms_key.opensearch.key_id
}
