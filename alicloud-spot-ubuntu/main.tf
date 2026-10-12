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

data "alicloud_images" "ubuntu" {
  name_regex  = "^ubuntu_22.*x64"
  most_recent = true
  owners      = "system"
}

resource "alicloud_vpc" "main" {
  vpc_name   = var.vpc_name
  cidr_block = "172.16.0.0/12"
}

resource "alicloud_vswitch" "main" {
  vpc_id     = alicloud_vpc.main.id
  cidr_block = "172.16.0.0/21"
  zone_id    = var.availability_zone
}

resource "alicloud_security_group" "sg" {
  name        = "spot-instance-sg"
  description = "Security group for spot instance"
  vpc_id      = alicloud_vpc.main.id
}

resource "alicloud_security_group_rule" "allow_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "22/22"
  priority          = 1
  security_group_id = alicloud_security_group.sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_icmp" {
  type              = "ingress"
  ip_protocol       = "icmp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "-1/-1"
  priority          = 1
  security_group_id = alicloud_security_group.sg.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_instance" "spot_ubuntu" {
  instance_name   = var.instance_name
  host_name       = var.instance_name
  image_id        = data.alicloud_images.ubuntu.images.0.id
  instance_type   = var.instance_type
  vswitch_id      = alicloud_vswitch.main.id
  security_groups = [alicloud_security_group.sg.id]

  spot_strategy    = "SpotAsPriceGo"
  spot_price_limit = var.spot_price_limit

  internet_max_bandwidth_out = var.internet_bandwidth
  internet_charge_type       = "PayByTraffic"

  system_disk_category = "cloud_essd"
  system_disk_size     = var.disk_size

  password = var.password
  # key_name = var.key_name
}