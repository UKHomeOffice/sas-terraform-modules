output "arn" {
  description = "ARN of the domain."
  value       = aws_opensearch_domain.domain.arn
}

output "availability_zones" {
  description = "If the domain was created inside a VPC, the names of the availability zones the configured subnet_ids were created inside."
  value       = aws_opensearch_domain.domain.vpc_options.0.availability_zones
}

output "domain_id" {
  description = "Unique identifier for the domain."
  value       = aws_opensearch_domain.domain.domain_id
}

output "domain_name" {
  description = "Name of the opensearch domain."
  value       = aws_opensearch_domain.domain.domain_name
}

output "endpoint" {
  description = "Domain-specific endpoint used to submit index, search, and data upload requests."
  value       = aws_opensearch_domain.domain.endpoint
}

output "kibana_endpoint" {
  description = "Domain-specific endpoint for kibana without https scheme."
  value       = aws_opensearch_domain.domain.kibana_endpoint
}

output "master_password" {
  description = "The randomly generated password for the OpenSearch domain."
  sensitive   = true
  value       = random_password.master_password.result
}

output "master_username" {
  description = "The randomly generated username for the OpenSearch domain."
  value       = random_string.master_username.result
}

output "security_group_ids" {
  description = "The list of VPC Security Groups attached to the OpenSearch domain."
  value       = aws_opensearch_domain.domain.vpc_options[0].security_group_ids
}

output "tags_all" {
  description = "Map of tags assigned to the resource, including those inherited from the provider default_tags configuration block."
  value       = aws_opensearch_domain.domain.tags_all
}

output "vpc_id" {
  description = "If the domain was created inside a VPC, the ID of the VPC."
  value       = aws_opensearch_domain.domain.vpc_options[0].vpc_id
}
