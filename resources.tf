# kics-scan disable=e38a8e0a-b88b-4902-b3fe-b0fcb17d5c10

# Used as a non collider in instances (such as final snapshot)
resource "random_string" "id" {
  length  = 8
  special = false
  upper   = false
  numeric = false
}

# # Used as the admin password. Not settable by the user on new builds.
# resource "random_password" "rds" {
#   length           = 32
#   special          = true
#   override_special = "!#$%&*()-_=+[]{}<>:?"
# }

# Used when var.random_port = true
resource "random_integer" "rds" {
  min = 1150
  max = 1433
}

# Dynamically generated from var.parameter_group_family and var.parameter_group_parameters for simplicity
resource "aws_db_parameter_group" "rds" {
  name   = "rds-${var.service}-${var.environment}"
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameter_group_parameters
    content {
      name  = parameter.value["name"]
      value = parameter.value["value"]
    }
  }

  tags = merge(
    { "Name" : "pg-rds-${var.service}-${var.environment}" },
    var.tags
  )
}