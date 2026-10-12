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
}

data "alicloud_zones" "default" {
  available_disk_category     = "cloud_efficiency"
  available_resource_creation = "VSwitch"
  available_instance_type     = var.instance_type
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

resource "alicloud_security_group_rule" "allow_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.group.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_icmp" {
  type              = "ingress"
  ip_protocol       = "icmp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.group.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_instance" "spot_instance" {
  availability_zone = data.alicloud_zones.default.zones.0.id
  security_groups   = [alicloud_security_group.group.id]
  instance_type     = var.instance_type
  image_id          = var.image_id
  instance_name     = var.name
  vswitch_id        = alicloud_vswitch.vswitch.id

  system_disk_category        = "cloud_efficiency"
  internet_max_bandwidth_out  = 10

  # Spot instance configuration
  instance_charge_type = "PostPaid"
  spot_strategy        = "SpotAsPriceGo"
  spot_duration        = 1

  password = var.password
}