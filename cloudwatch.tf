# kics-scan disable=e38a8e0a-b88b-4902-b3fe-b0fcb17d5c10,e592a0c5-5bdb-414c-9066-5dba7cdea370,ef0b316a-211e-42f1-888e-64efe172b755

resource "aws_cloudwatch_log_resource_policy" "opensearch_log_publishing_policy" {
  policy_document = data.aws_iam_policy_document.opensearch_log_publishing_policy.json
  policy_name     = "os-${var.domain_name}-logs"
}

resource "aws_cloudwatch_log_group" "audit" {
  name              = local.audit_logs
  kms_key_id        = aws_kms_key.logs.arn
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags, { Name = local.audit_logs }
  )
}

resource "aws_cloudwatch_log_group" "application" {
  name              = local.application_logs
  kms_key_id        = aws_kms_key.logs.arn
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags, { Name = local.application_logs }
  )
}

resource "aws_cloudwatch_log_group" "index_slow" {
  name              = local.index_slow_logs
  kms_key_id        = aws_kms_key.logs.arn
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags, { Name = local.index_slow_logs }
  )
}

resource "aws_cloudwatch_log_group" "search_slow" {
  name              = local.search_slow_logs
  kms_key_id        = aws_kms_key.logs.arn
  retention_in_days = var.log_retention_days

  tags = merge(
    var.tags,
    { Name = local.search_slow_logs }
  )
}
