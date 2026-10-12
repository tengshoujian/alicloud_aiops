variable "region" {
  type        = string
  description = "AliCloud region"
  default     = "cn-hangzhou"
}

variable "password" {
  type        = string
  description = "Root password for the instance"
  sensitive   = true
  default     = null
}