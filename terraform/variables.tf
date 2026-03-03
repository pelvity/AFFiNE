variable "aws_region" {
  description = "AWS region for deployment"
  type        = string
  default     = "eu-north-1" # Based on your current setup
}

variable "instance_type" {
  description = "EC2 Instance type"
  type        = string
  default     = "t3.micro" # Testing if t3.micro bypasses the weird Free Tier error
}

variable "key_name" {
  description = "Name of the SSH key pair"
  type        = string
  default     = "grindolko"
}
