terraform {
  required_version = ">= 1.6.3"
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

resource "yandex_vpc_network" "this" {
  name        = var.network_name
  description = "Сеть, созданная модулем"
}

resource "yandex_vpc_subnet" "this" {
  count          = length(var.subnets)
  name           = var.subnets[count.index].name
  zone           = var.subnets[count.index].zone
  v4_cidr_blocks = var.subnets[count.index].v4_cidr_blocks
  network_id     = yandex_vpc_network.this.id
}
