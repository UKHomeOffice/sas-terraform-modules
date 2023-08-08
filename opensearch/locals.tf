locals {
  aws_account_id          = data.aws_caller_identity.current.account_id
  default_opensearch_port = 443
  index_slow_logs         = "os-${var.domain_name}-index-slow"
  search_slow_logs        = "os-${var.domain_name}-search-slow"
  application_logs        = "os-${var.domain_name}-application"
  audit_logs              = "os-${var.domain_name}-audit"
}
