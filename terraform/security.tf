data "external" "myipaddr" {
  program = ["bash", "-c", "curl -s 'https://api.ipify.org?format=json'"]
}

resource "hcloud_firewall" "firewall_general" {
  name = "firewall-general"

  rule {
    description = "ssh"
    direction = "in"
    protocol  = "tcp"
    port      = "22"
    source_ips = [data.external.myipaddr.result.ip]
  }

  rule {
    description = "http"
    direction = "in"
    protocol  = "tcp"
    port      = "80"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }

  rule {
    description = "https"
    direction = "in"
    protocol  = "tcp"
    port      = "443"
    source_ips = [
      "0.0.0.0/0",
      "::/0"
    ]
  }
}

resource "hcloud_firewall" "k8s_cp_access" {
  name = "firewall-cp-access"

  rule {
    direction = "in"
    protocol  = "tcp"
    port      = "6443"
    source_ips = [data.external.myipaddr.result.ip]
  }
}

resource "hcloud_firewall" "firewall_all_k8s_nodes" {
  name = "firewall-all-k8s-nodes"

  rule {
    description = "k8s"
    direction   = "in"
    protocol    = "tcp"
    port        = "any"
    source_ips = [
      "10.0.0.0/8",
      "192.168.0.0/16",
      "172.16.0.0/12",
      "fc00::/7",
      "fe80::/10",
    ]
  }

  rule {
    description = "k8s-udp"
    direction   = "in"
    protocol    = "udp"
    port        = "any"
    source_ips = [
      "10.0.0.0/8",
      "192.168.0.0/16",
      "172.16.0.0/12",
      "fc00::/7",
      "fe80::/10",
    ]
  }

  rule {
    description = "k8s-ext"
    direction   = "in"
    protocol    = "tcp"
    port        = "any"
    source_ips = [for node in hcloud_server.nodes : node.ipv4_address]
  }

  rule {
    description = "k8s-ext-udp"
    direction   = "in"
    protocol    = "udp"
    port        = "any"
    source_ips = [for node in hcloud_server.nodes : node.ipv4_address]
  }
}
