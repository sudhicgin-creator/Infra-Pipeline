output "alb_dns_name" {
  value       = aws_lb.main.dns_name
  description = "ALB DNS name"
}

output "web_instance_ids" {
  value = aws_instance.web[*].id
}

output "web_instance_private_ips" {
  value = aws_instance.web[*].private_ip
}

output "rds_endpoint" {
  value = aws_db_instance.main.endpoint
}

output "rds_replica_endpoint" {
  value = aws_db_instance.replica.endpoint
}

output "vpc_id" {
  value = aws_vpc.main.id
}
