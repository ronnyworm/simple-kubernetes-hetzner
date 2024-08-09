resource "hcloud_ssh_key" "key" {
  name       = "my-ssh-key"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "hcloud_network" "my_net" {
  name     = "my-net"
  ip_range = "10.0.1.0/24"
}

resource "hcloud_network_subnet" "my_subnet" {
  network_id   = hcloud_network.my_net.id
  type         = "cloud"
  network_zone = "eu-central"
  ip_range     = "10.0.1.0/24"
}
