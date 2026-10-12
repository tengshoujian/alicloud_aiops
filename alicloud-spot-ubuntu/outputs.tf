output "instance_id" {
  value = alicloud_instance.spot_ubuntu.id
}

output "public_ip" {
  value = alicloud_instance.spot_ubuntu.public_ip
}

output "private_ip" {
  value = alicloud_instance.spot_ubuntu.private_ip
}