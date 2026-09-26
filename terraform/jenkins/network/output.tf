output "network_id" {
  value = yandex_vpc_network.this.id
}
output "subnet_ids" {
  value = yandex_vpc_subnet.this[*].id
}
output "subnet_names" {
  value = yandex_vpc_subnet.this[*].name
}
output "subnet_zones" {
  value = yandex_vpc_subnet.this[*].zone
}
