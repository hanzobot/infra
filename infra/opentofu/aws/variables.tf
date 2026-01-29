variable "aws_region" {
  description = "AWS region for the image bucket."
  type        = string
}

variable "bucket_name" {
  description = "S3 bucket name for image uploads."
  type        = string
  default     = "botctl-images-eu1-20260107165216"
}

variable "ci_user_name" {
  description = "IAM user used by CI."
  type        = string
  default     = "botctl-image-uploader"
}

variable "tags" {
  description = "Tags to apply to AWS resources."
  type        = map(string)
  default     = {}
}

variable "ami_id" {
  description = "AMI ID for BOTCTL instances."
  type        = string
  default     = ""
}

variable "instance_name" {
  description = "Name tag for the BOTCTL instance."
  type        = string
  default     = "botctl-1"
}

variable "instance_type" {
  description = "EC2 instance type."
  type        = string
  default     = "t3.small"
}

variable "root_volume_size_gb" {
  description = "Root EBS volume size in GiB."
  type        = number
  default     = 40
}

variable "ssh_public_key" {
  description = "SSH public key for the BOTCTL operator."
  type        = string
  default     = ""
  validation {
    condition     = var.ami_id == "" || length(var.ssh_public_key) > 0
    error_message = "ssh_public_key is required when ami_id is set."
  }
}

variable "allowed_cidrs" {
  description = "CIDR ranges allowed to SSH and the gateway."
  type        = list(string)
  default     = ["0.0.0.0/0"]
}
