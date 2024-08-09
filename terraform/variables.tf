variable "server_type" {
  type    = string
  default = "cx22"
}

variable "server_image" {
  type    = string
  default = "ubuntu-20.04"
}

variable "node_count" {
  type    = number
  default = 3
}
