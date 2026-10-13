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

data "alicloud_images" "windows_2016" {
  owners      = "system"
  name_regex  = "^win2016"
  os_type     = "windows"
  most_recent = true
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

resource "alicloud_security_group_rule" "allow_rdp" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "3389/3389"
  security_group_id = alicloud_security_group.group.id
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_security_group_rule" "allow_ssh" {
  type              = "ingress"
  ip_protocol       = "tcp"
  port_range        = "22/22"
  security_group_id = alicloud_security_group.group.id
  cidr_ip           = "0.0.0.0/0"
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
  internet_max_bandwidth_out = 0
  instance_charge_type = "PostPaid"
  spot_strategy        = "SpotAsPriceGo"
  spot_duration        = 1
  password             = "Grafana2024!"
}

# 创建 Windows Server 2016 实例并安装 AD Domain Services
resource "alicloud_instance" "windows_dc" {
  count                  = 2
  availability_zone      = data.alicloud_zones.default.zones.0.id
  security_groups        = [alicloud_security_group.group.id]
  instance_type          = "ecs.e-c1m2.large"
  image_id               = data.alicloud_images.windows_2016.images.0.id
  instance_name          = "${var.name}-win-dc-${count.index + 1}"
  vswitch_id             = alicloud_vswitch.vswitch.id
  system_disk_category   = "cloud_essd"
  internet_max_bandwidth_out = 0
  password               = "YourStrongPassword123!"
  user_data              = base64encode(<<-EOF
    <powershell>
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -Restart
    </powershell>
    EOF
  )
}

# 为 Ubuntu 实例创建并绑定 EIP
resource "alicloud_eip_address" "eip_ubuntu" {
  address_name         = "${var.name}-ubuntu-eip"
  bandwidth            = "5"
  internet_charge_type = "PayByTraffic"
  payment_type         = "PayAsYouGo"
}

resource "alicloud_eip_association" "eip_assoc_ubuntu" {
  allocation_id = alicloud_eip_address.eip_ubuntu.id
  instance_id   = alicloud_instance.spot_instance.id
}

# 为第一台 Windows Server 2016 创建 EIP
resource "alicloud_eip" "win_eip_1" {
  address_name         = "${var.name}-win-eip-1"
  bandwidth            = "5"
  internet_charge_type = "PayByTraffic"
  payment_type         = "PayAsYouGo"
}

# 为第二台 Windows Server 2016 创建 EIP
resource "alicloud_eip" "win_eip_2" {
  address_name         = "${var.name}-win-eip-2"
  bandwidth            = "5"
  internet_charge_type = "PayByTraffic"
  payment_type         = "PayAsYouGo"
}

# 第一台 Windows Server 2016 实例（安装域控制器）
resource "alicloud_instance" "windows_dc_1" {
  availability_zone      = data.alicloud_zones.default.zones.0.id
  security_groups        = [alicloud_security_group.group.id]
  instance_type          = "ecs.g6.large"
  image_id               = data.alicloud_images.windows_2016.images.0.id
  instance_name          = "${var.name}-win-dc-1"
  vswitch_id             = alicloud_vswitch.vswitch.id
  system_disk_category   = "cloud_efficiency"
  internet_max_bandwidth_out = 0
  user_data              = base64encode(<<-EOF
    # Install AD DS and promote to Domain Controller
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -Restart
    Import-Module ADDSDeployment
    Install-ADDSForest `
      -DomainName "corp.example.com" `
      -SafeModeAdministratorPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) `
      -InstallDns:$true `
      -Force:$true
  EOF
  )
}

# 第二台 Windows Server 2016 实例（安装域控制器）
resource "alicloud_instance" "windows_dc_2" {
  availability_zone      = data.alicloud_zones.default.zones.0.id
  security_groups        = [alicloud_security_group.group.id]
  instance_type          = "ecs.g6.large"
  image_id               = data.alicloud_images.windows_2016.images.0.id
  instance_name          = "${var.name}-win-dc-2"
  vswitch_id             = alicloud_vswitch.vswitch.id
  system_disk_category   = "cloud_efficiency"
  internet_max_bandwidth_out = 0
  user_data              = base64encode(<<-EOF
    # Install AD DS and promote to Domain Controller
    Install-WindowsFeature -Name AD-Domain-Services -IncludeManagementTools -Restart
    Import-Module ADDSDeployment
    Install-ADDSForest `
      -DomainName "corp.example.com" `
      -SafeModeAdministratorPassword (ConvertTo-SecureString "P@ssw0rd123!" -AsPlainText -Force) `
      -InstallDns:$true `
      -Force:$true
  EOF
  )
}

# 将 EIP 绑定到第一台 Windows 实例
resource "alicloud_eip_association" "win_eip_assoc_1" {
  allocation_id = alicloud_eip.win_eip_1.id
  instance_id   = alicloud_instance.windows_dc_1.id
  instance_type = "EcsInstance"
}

# 将 EIP 绑定到第二台 Windows 实例
resource "alicloud_eip_association" "win_eip_assoc_2" {
  allocation_id = alicloud_eip.win_eip_2.id
  instance_id   = alicloud_instance.windows_dc_2.id
  instance_type = "EcsInstance"
}