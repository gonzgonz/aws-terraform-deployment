output "alb_dns_name" {
  value = aws_lb.cint_infrastructure.dns_name
}

output "application_http_endpoint" {
  value       = "http://${aws_lb.cint_infrastructure.dns_name}"
  description = "please use this endpoint to test the application"
}

output "rds_dns_endpoint" {
  value = aws_db_instance.rds_instance.endpoint
}
