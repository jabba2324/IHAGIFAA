locals {
  common_tags = {
    Environment = var.environment
    AppName     = var.app_name
    ManagedBy   = "terraform"
  }

  # Size-based configurations
  size_config = {
    small = {
      ecs_cpu           = 256
      ecs_memory        = 512
      aurora_min_acu    = 0.5
      aurora_max_acu    = 1
      alb_type          = "application"
    }
    medium = {
      ecs_cpu           = 512
      ecs_memory        = 1024
      aurora_min_acu    = 0.5
      aurora_max_acu    = 2
      alb_type          = "application"
    }
    large = {
      ecs_cpu           = 1024
      ecs_memory        = 2048
      aurora_min_acu    = 1
      aurora_max_acu    = 4
      alb_type          = "application"
    }
  }

  bucket_hash = substr(sha256("${var.app_name}-${var.environment}"), 0, 8)
}