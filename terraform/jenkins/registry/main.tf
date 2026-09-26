terraform {
  required_version = ">= 1.6.3"
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

resource "yandex_container_registry" "this" {
  name = "registry"
}
