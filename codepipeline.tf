# EventBridge rule for ECR image push
resource "aws_cloudwatch_event_rule" "ecr_push" {
  name = "${var.app_name}-ecr-push"
  
  event_pattern = jsonencode({
    source      = ["aws.ecr"]
    detail-type = ["ECR Image Action"]
    detail = {
      action-type     = ["PUSH"]
      repository-name = [aws_ecr_repository.app.name]
      image-tag       = ["latest"]
    }
  })
  
  tags = local.common_tags
}

# CodePipeline
resource "aws_codepipeline" "app" {
  name     = "${var.app_name}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn
  
  artifact_store {
    location = aws_s3_bucket.pipeline_artifacts.bucket
    type     = "S3"
  }
  
  stage {
    name = "Source"
    
    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "ECR"
      version          = "1"
      output_artifacts = ["source_output"]
      
      configuration = {
        RepositoryName = aws_ecr_repository.app.name
        ImageTag       = "latest"
      }
    }
  }
  
  stage {
    name = "Deploy"
    
    action {
      name            = "Deploy"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["source_output"]
      
      configuration = {
        ClusterName = aws_ecs_cluster.main.name
        ServiceName = aws_ecs_service.app.name
      }
    }
  }
  
  tags = local.common_tags
}

# S3 bucket for pipeline artifacts
resource "aws_s3_bucket" "pipeline_artifacts" {
  bucket = "${local.bucket_hash}-${var.app_name}-pipeline"
  
  tags = local.common_tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "pipeline_artifacts" {
  bucket = aws_s3_bucket.pipeline_artifacts.id
  
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# EventBridge target
resource "aws_cloudwatch_event_target" "codepipeline" {
  rule      = aws_cloudwatch_event_rule.ecr_push.name
  target_id = "CodePipelineTarget"
  arn       = aws_codepipeline.app.arn
  role_arn  = aws_iam_role.eventbridge.arn
}