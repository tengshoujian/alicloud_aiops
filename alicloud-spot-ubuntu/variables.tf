variable "region" {
  type        = string
  description = "AliCloud region"
  default     = "cn-hangzhou"
}

variable "name" {
  type        = string
  description = "Resource name prefix"
  default     = "terraform-spot-example"
}

variable "instance_type" {
  type        = string
  description = "ECS instance type"
  default     = "ecs.n4.large"
}

variable "image_id" {
  type        = string
  description = "Image ID for the instance"
  default     = "ubuntu_22_04_x64_20G_alibase_20240828.vhd"
}

variable "password" {
  type        = string
  description = "Root password for the instance"
  sensitive   = true
  default     = null
}