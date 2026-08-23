variable "aws_region" {
  description = "AWS region in which to provision the VM."
  type        = string
  default     = "us-east-1"
}

variable "instance_type" {
  description = "EC2 instance type for the webtext-app VM."
  type        = string
  default     = "t3.micro"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access."
  type        = string
}

variable "ssh_cidr" {
  description = "CIDR block allowed to SSH to the VM."
  type        = string
}

