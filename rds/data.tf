data "aws_subnets" "rds_subnets" {
  filter {
    name   = "tag:subnet_name"
    values = [var.subnet_name]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.bus_vpc.id]
  }
}

data "aws_vpc" "bus_vpc" {
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