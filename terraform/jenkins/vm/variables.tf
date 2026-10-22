variable "network_id" {
  type = string
}

variable "subnet_id" {
  type = string
}

variable "subnet_zone" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "memory" {
  type = number
}

variable "disk_size" {
  type    = number
  default = 10
}

variable "core_fraction" {
  type    = number
  default = 20
}

variable "instance_name" {
  type = string
}

variable "security_group_name" {
  type = string
}

variable "disk_name" {
  type = string
}

variable "ingress_rules" {
  type = list(object({
    port           = number
    v4_cidr_blocks = list(string)
  }))
}
