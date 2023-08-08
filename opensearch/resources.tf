resource "random_string" "master_username" {
  length  = 16
  special = false
}

resource "random_password" "master_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
  min_special      = 1
  min_upper        = 1
  min_lower        = 1
  min_numeric      = 1
}