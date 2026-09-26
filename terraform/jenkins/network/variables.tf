variable "network_name" {
  type        = string
  description = "Имя сети"
}

variable "subnets" {
  type = list(object({
    name           = string
    zone           = string
    v4_cidr_blocks = list(string)
  }))
  description = "Список подсетей"
}
