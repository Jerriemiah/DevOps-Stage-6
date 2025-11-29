variable "aws_region" {
  default = "us-east-1"
}

variable "instance_type" {
  default = "t3.medium"
}

variable "key_name" {
  description = "SSH key pair name for EC2"
}

variable "public_key_path" {
  description = "Path to your local public SSH key"
}

