variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Short name used to prefix/tag all resources"
  type        = string
  default     = "capstone-static-web"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for the two public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "availability_zones" {
  description = "AZs to place the public subnets in. Leave empty to auto-pick the first two AZs in the region."
  type        = list(string)
  default     = []
}

variable "my_ip_cidr" {
  description = "Your IP address in CIDR form (e.g. 203.0.113.42/32), used to restrict SSH access. Required."
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t2.micro"
}

variable "key_pair_name" {
  description = "Name of an existing EC2 key pair to enable SSH access"
  type        = string
}

variable "bucket_name" {
  description = "Globally unique S3 bucket name for website assets/backups"
  type        = string
}

variable "alert_email" {
  description = "Email address to subscribe to the SNS alarm topic"
  type        = string
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization percentage that triggers the CloudWatch alarm"
  type        = number
  default     = 70
}
