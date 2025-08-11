variable "subdomain" {
  description = "Subdomain for the Route53 zone"
  type        = string
}

variable "app_name" {
  description = "Application name used as prefix for all resources"
  type        = string
}

variable "environment" {
  description = "Environment tag for resources"
  type        = string
}

variable "size" {
  description = "Size of the deployment (small, medium, large)"
  type        = string
  validation {
    condition     = contains(["small", "medium", "large"], var.size)
    error_message = "Size must be small, medium, or large."
  }
}

variable "region" {
  description = "AWS region for deployment"
  type        = string
}

variable "environment_variables" {
  description = "Additional environment variables for the ECS container"
  type        = map(string)
  default     = {}
}