variable "region" {
  type    = string
  default = "ap-northeast-1"
}


variable "password" {
  type        = string
  description = "Root password for the instance"
  sensitive   = true
  default     = null
}