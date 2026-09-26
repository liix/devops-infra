terraform {
  required_version = ">= 1.6.3"
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

resource "yandex_vpc_security_group" "this" {
  name       = "security-group"
  network_id = var.network_id

  ingress {
    protocol       = "TCP"
    port           = 22
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    protocol       = "TCP"
    port           = 8080
    v4_cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol       = "ANY"
    v4_cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "yandex_compute_instance" "this" {
  name        = "vm"
  hostname    = "vm"
  zone        = var.subnet_zone
  platform_id = "standard-v3"

  boot_disk {
    initialize_params {
      name       = "disk-ubuntu-24-04-lts"
      type       = "network-hdd"
      size       = 10
      block_size = 4096
      image_id   = "fd8s63gg3op17u27s4oa"
    }
    auto_delete = true
  }

  network_interface {
    subnet_id          = var.subnet_id
    index              = 0
    nat                = true
    security_group_ids = [yandex_vpc_security_group.this.id]
  }

  resources {
    memory        = 2
    cores         = 2
    core_fraction = 20
    gpus          = 0
  }

  scheduling_policy {
    preemptible = false
  }

  metadata = {
    ssh-keys = "ubuntu:${var.ssh_public_key}"
  }
}
