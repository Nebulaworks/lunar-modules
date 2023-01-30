# Keep outputs to resource IDs if additional info is needed outside the module then best to
# leverage data resources
output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.this.id
}

output "private_subnets_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.private[*].id
}

output "public_subnets_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.public[*].id
}

output "public_route_table_ids" {
  description = "List of IDs of public route tables"
  value       = aws_route_table.public[*].id
}

output "private_route_table_ids" {
  description = "List of IDs of private route tables"
  value       = aws_route_table.private[*].id
}

output "eip_nat_ids" {
  description = "List of IDs of EIPs for AWS NAT Gateway"
  value       = aws_eip.this[*].id
}

output "nat_gw_ids" {
  description = "List of NAT Gateway IDs"
  value       = aws_nat_gateway.this[*].id
}

output "igw_id" {
  description = "Internet Gateway ID"
  value       = aws_internet_gateway.this[0].id
}
