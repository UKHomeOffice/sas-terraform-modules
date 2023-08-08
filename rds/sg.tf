# kics-scan disable=e38a8e0a-b88b-4902-b3fe-b0fcb17d5c10

resource "aws_security_group" "rds" {
  vpc_id      = data.aws_vpc.bus_vpc.id
  name        = "sgrds-${var.service}-${var.environment}"
  description = "Security group for sgrds-${var.service}-${var.environment}"

  tags = merge(
    { "Name" : "sg-${var.service}-${var.environment}" },
    var.tags
  )
}