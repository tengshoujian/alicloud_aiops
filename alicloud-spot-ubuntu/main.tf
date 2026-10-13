terraform {
  required_providers {
    alicloud = {
      source  = "aliyun/alicloud"
      version = "~> 1.229"
    }
  }
}

provider "alicloud" {
  region = var.region
  # Authentication: set environment variables ALICLOUD_ACCESS_KEY and ALICLOUD_SECRET_KEY
  # Alternatively, uncomment and use variables below (but keep them out of version control)
  # access_key = var.access_key
  # secret_key = var.secret_key
}



data "alicloud_zones" "default" {
  available_disk_category     = "cloud_essd"
  available_resource_creation = "VSwitch"
  available_instance_type     = "ecs.e-c1m2.large"
}

variable "name" {
  default = "terraform-spot-example"
}



data "alicloud_images" "ubuntu" {
  owners       = "system"
  name_regex   = "^ubuntu"
  architecture = "x86_64"
  most_recent  = true
  status       = "Available"
}

resource "alicloud_vpc" "vpc" {
  vpc_name   = var.name
  cidr_block = "172.16.0.0/16"
}

resource "alicloud_vswitch" "vswitch" {
  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = "172.16.0.0/24"
  zone_id      = data.alicloud_zones.default.zones.0.id
  vswitch_name = var.name
}

resource "alicloud_security_group" "group" {
  security_group_name = var.name
  description         = "Security group for spot instance"
  vpc_id              = alicloud_vpc.vpc.id
}

resource "alicloud_instance" "spot_instance" {
  availability_zone      = data.alicloud_zones.default.zones.0.id
  security_groups        = [alicloud_security_group.group.id]
  instance_type          = "ecs.e-c1m2.large"
  image_id               = data.alicloud_images.ubuntu.images.0.id
  instance_name          = var.name
  vswitch_id             = alicloud_vswitch.vswitch.id
  system_disk_category   = "cloud_essd"
  system_disk_name       = var.name
  internet_max_bandwidth_out = 10
  instance_charge_type = "PostPaid"
  spot_strategy        = "SpotAsPriceGo"
  spot_duration        = 1
  password             = "Grafana2024!"
}