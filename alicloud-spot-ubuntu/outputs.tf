output "instance_id" {
  value = alicloud_instance.spot_instance.id
}

output "public_ip" {
  value = alicloud_instance.spot_instance.public_ip
}

output "private_ip" {
  value = alicloud_instance.spot_instance.private_ip
}