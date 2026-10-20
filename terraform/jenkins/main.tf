terraform {
  required_version = ">= 1.6.3"
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  folder_id                = var.folder_id
  zone                     = "ru-central1-d"
  cloud_id                 = var.cloud_id
  service_account_key_file = "../key.json"
}

module "network" {
  source       = "./network"
  network_name = "network"
  subnets = [
    {
      name           = "subnet1"
      zone           = "ru-central1-d"
      v4_cidr_blocks = ["10.10.1.0/24"]
    },
    {
      name           = "subnet2"
      zone           = "ru-central1-e"
      v4_cidr_blocks = ["10.10.2.0/24"]
    }
  ]
}

module "vm" {
  source         = "./vm"
  network_id     = module.network.network_id
  subnet_id      = module.network.subnet_ids[0]
  subnet_zone    = module.network.subnet_zones[0]
  ssh_public_key = var.ssh_public_key
}

module "registry" {
  source = "./registry"
}

output "vm_ip" {
  value = module.vm.vm_ip
}

output "registry_id" {
  value = module.registry.registry_id
}

