# kics-scan disable=e38a8e0a-b88b-4902-b3fe-b0fcb17d5c10

resource "aws_security_group" "default" {
  #checkov:skip=CKV2_AWS_5:false positive
  vpc_id      = data.aws_vpc.sip_vpc.id
  name        = "sgos-${var.domain_name}"
  description = "Security group for the ${var.domain_name} Opensearch domain."
  tags = merge(
    var.tags,
    { Name = "sges-${var.domain_name}" }
  )
}