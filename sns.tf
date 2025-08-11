# SNS Topic for Events
resource "aws_sns_topic" "events" {
  name = "${var.app_name}-events"
  
  tags = local.common_tags
}