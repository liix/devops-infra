output "vm_id" {
  value = yandex_compute_instance.this.id
}

output "vm_ip" {
  value = yandex_compute_instance.this.network_interface[0].nat_ip_address
}

output "vm_internal_ip" {
  value = yandex_compute_instance.this.network_interface[0].ip_address
}
