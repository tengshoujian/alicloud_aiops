variable "region" {
  description = "Alibaba Cloud region"
  type        = string
  default     = "cn-hangzhou"
}

variable "vpc_name" {
  description = "VPC name"
  type        = string
  default     = "spot-instance-vpc"
}

variable "availability_zone" {
  description = "Availability zone"
  type        = string
  default     = "cn-hangzhou-b"
}

variable "instance_name" {
  description = "Instance name"
  type        = string
  default     = "spot-ubuntu"
}

variable "instance_type" {
  description = "ECS instance type"
  type        = string
  default     = "ecs.t6-c1m1.large"
}

variable "spot_price_limit" {
  description = "Max price per hour (0 = SpotAsPriceGo)
  type        = number
  default     = 0
}

variable "internet_bandwidth" {
  description = "Internet max bandwidth (Mbps)"
  type        = number
  default     = 1
}

variable "disk_size" {
  description = "System disk size (GB)"
  type        = number
  default     = 40
}

variable "password" {
  description = "Root password (leave null to use key pair)"
  type        = string
  sensitive   = true
  default     = null
}

variable "key_name" {
  description = "SSH key pair name (optional)"
  type        = string
  default     = null
}