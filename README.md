# IHAGIFAA AWS Terraform Module

I Have A Great Idea For An App. An opinionated Terraform module for deploying a complete webapp infrastructure on AWS, comparable to something like vercel or supabase.

## Features

- Route 53 hosted zone
- Private VPC with public/private subnets
- Application Load Balancer (ALB) with SSL
- ECS Fargate cluster
- ECR repository for Docker images
- CodePipeline for automated deployments
- RDS PostgreSQL database
- SNS topic for events
- S3 bucket for objects (with hash prefix)

## Usage

```hcl
module "webapp" {
  source = "./ihagifaa"
  
  subdomain   = "myapp.example.com"
  app_name    = "myapp"
  environment = "production"
  size        = "medium"
  region      = "us-west-2"
  
  environment_variables = {
    NODE_ENV = "production"
    API_KEY  = "your-api-key"
  }
}
```

## Important Notes

- **Subdomain Control**: This module creates a Route 53 hosted zone for the entire subdomain. You must update your domain's nameservers to point to the AWS nameservers (available in outputs) for the subdomain to work.
- **SSL Certificate**: After applying, monitor the certificate validation status. The SSL certificate will only validate once the nameservers are properly configured and DNS propagation is complete.

## Variables

| Name | Description | Type | Required |
|------|-------------|------|----------|
| subdomain | Subdomain for Route53 zone | string | yes |
| app_name | Application name (resource prefix) | string | yes |
| environment | Environment tag | string | yes |
| size | Deployment size (small/medium/large) | string | yes |
| region | AWS region | string | yes |
| environment_variables | Additional environment variables for ECS | map(string) | no |

## Size Configurations

| Size | ECS CPU | ECS Memory | Aurora Capacity |
|------|---------|------------|----------------|
| small | 256 | 512 MB | 0.5-1 ACU |
| medium | 512 | 1024 MB | 0.5-2 ACU |
| large | 1024 | 2048 MB | 1-4 ACU |

## Outputs

- `route53_zone_id` - Route53 zone ID
- `route53_name_servers` - Route53 name servers
- `alb_dns_name` - ALB DNS name
- `ecs_cluster_name` - ECS cluster name
- `rds_endpoint` - RDS endpoint (sensitive)
- `rds_password` - RDS password (sensitive)
- `sns_topic_arn` - SNS topic ARN
- `s3_bucket_name` - S3 bucket name
- `ecr_repository_url` - ECR repository URL
- `codepipeline_name` - CodePipeline name

## Deploying Your Application

Deployment is fully automated! Simply push your Docker image with the `latest` tag:

```bash
# Build your image
docker build -t myapp .

# Get ECR login token
aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin {ecr_repository_url}

# Tag and push to ECR
docker tag myapp:latest {ecr_repository_url}:latest
docker push {ecr_repository_url}:latest
```

That's it! The CodePipeline will automatically:
1. Detect the new image push
2. Update your ECS service
3. Deploy with zero downtime

### Manual Deployment (if needed)
If you need to deploy manually or use a different tag:

```bash
# Update ECS service directly
aws ecs update-service \
  --cluster {ecs_cluster_name} \
  --service {app_name}-service \
  --force-new-deployment
```

### Environment Variables Available
Your application will have access to:
- `DATABASE_URL` - PostgreSQL connection string
- `S3_BUCKET_NAME` - S3 bucket for file storage
- `SNS_TOPIC_ARN` - SNS topic for events
- `AWS_REGION` - Current AWS region