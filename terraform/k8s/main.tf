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
  zone                     = "ru-central1-a"
  cloud_id                 = var.cloud_id
  service_account_key_file = "../key.json"
}

data "yandex_vpc_network" "this" {
  name = "network"
}

data "yandex_vpc_subnet" "this" {
  name = "subnet1"
}

resource "yandex_iam_service_account" "this" {
  name        = "master-sa"
  description = "sa for creating resources"
  folder_id   = var.folder_id
}

resource "yandex_resourcemanager_folder_iam_member" "this" {
  for_each = toset([
    "k8s.clusters.agent",
    "vpc.publicAdmin",
    "container-registry.images.puller",
  ])
  folder_id = var.folder_id
  role      = each.value
  member    = "serviceAccount:${yandex_iam_service_account.this.id}"
}

module "kubernetes" {
  source       = "./kubernetes"
  network_id   = data.yandex_vpc_network.this.id
  subnet_id    = data.yandex_vpc_subnet.this.id
  master_sa_id = yandex_iam_service_account.this.id
  node_sa_id   = yandex_iam_service_account.this.id
  depends_on   = [yandex_resourcemanager_folder_iam_member.this]
}
