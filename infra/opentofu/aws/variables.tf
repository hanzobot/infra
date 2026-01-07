variable "aws_region" {
  description = "AWS region for the image bucket."
  type        = string
}

variable "bucket_name" {
  description = "Existing S3 bucket name for image uploads."
  type        = string
  default     = "clawdinator-images-eu1-20260107165216"
}

variable "tags" {
  description = "Tags to apply to AWS resources."
  type        = map(string)
  default     = {}
}
