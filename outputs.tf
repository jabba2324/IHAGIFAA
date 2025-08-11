output "route53_zone_id" {
  description = "Route53 zone ID"
  value       = aws_route53_zone.main.zone_id
}

output "route53_name_servers" {
  description = "Route53 name servers"
  value       = aws_route53_zone.main.name_servers
}

output "alb_dns_name" {
  description = "ALB DNS name"
  value       = aws_lb.main.dns_name
}

output "alb_zone_id" {
  description = "ALB zone ID"
  value       = aws_lb.main.zone_id
}

output "ssl_certificate_arn" {
  description = "SSL certificate ARN"
  value       = aws_acm_certificate.main.arn
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.main.name
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_rds_cluster.main.endpoint
  sensitive   = true
}

output "rds_password" {
  description = "RDS password"
  value       = random_password.db_password.result
  sensitive   = true
}

output "sns_topic_arn" {
  description = "SNS topic ARN"
  value       = aws_sns_topic.events.arn
}

output "s3_bucket_name" {
  description = "S3 bucket name"
  value       = aws_s3_bucket.objects.bucket
}

output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.app.repository_url
}

output "codepipeline_name" {
  description = "CodePipeline name"
  value       = aws_codepipeline.app.name
}