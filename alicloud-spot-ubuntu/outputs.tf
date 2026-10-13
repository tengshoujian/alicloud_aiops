output "vpc_id" {
  value = alicloud_vpc.vpc.id
}

output "vswitch_id" {
  value = alicloud_vswitch.vswitch.id
}

output "security_group_id" {
  value = alicloud_security_group.group.id
}

output "spot_instance_id" {
  value = alicloud_instance.spot_instance.id
}

output "spot_instance_public_ip" {
  value = alicloud_instance.spot_instance.public_ip
}

output "spot_instance_private_ip" {
  value = alicloud_instance.spot_instance.private_ip
}

output "windows_dc_1_id" {
  value = alicloud_instance.windows_dc_1.id
}

output "windows_dc_1_private_ip" {
  value = alicloud_instance.windows_dc_1.private_ip
}

output "windows_dc_2_id" {
  value = alicloud_instance.windows_dc_2.id
}

output "windows_dc_2_private_ip" {
  value = alicloud_instance.windows_dc_2.private_ip
}

output "ubuntu_eip_public_ip" {
  value = alicloud_eip_address.eip_ubuntu.ip_address
}

output "win_eip_1_public_ip" {
  value = alicloud_eip.win_eip_1.ip_address
}

output "win_eip_2_public_ip" {
  value = alicloud_eip.win_eip_2.ip_address
}
