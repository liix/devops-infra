terraform {
  required_version = ">= 1.6.3"
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

resource "yandex_kubernetes_cluster" "this" {
  name                     = "k8s-cluster"
  network_id               = var.network_id
  node_ipv4_cidr_mask_size = 24
  service_account_id       = var.master_sa_id
  node_service_account_id  = var.node_sa_id
  release_channel          = "REGULAR"

  master {
    version   = "1.35"
    public_ip = true
    zonal {
      zone      = "ru-central1-d"
      subnet_id = var.subnet_id
    }
    maintenance_policy {
      auto_upgrade = true
      maintenance_window {
        duration   = "24h"
        start_time = "00:00"
      }
    }
  }

  workload_identity_federation {
    enabled = false
  }
}

resource "yandex_kubernetes_node_group" "this" {
  cluster_id = yandex_kubernetes_cluster.this.id
  name       = "k8s-node-group"

  instance_template {
    platform_id = "standard-v2"

    network_interface {
      nat        = true
      subnet_ids = [var.node_subnet_id]
    }

    resources {
      memory        = 2
      cores         = 2
      core_fraction = 100
    }

    boot_disk {
      type = "network-hdd"
      size = 20
    }

    container_runtime {
      type = "containerd"
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  allocation_policy {
    location {
      zone = "ru-central1-e"
    }
  }

  workload_identity_federation {
    enabled = false
  }
}
