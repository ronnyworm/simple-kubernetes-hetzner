resource "hcloud_server" "nodes" {
  count       = var.node_count
  name        = "node${count.index}"
  image       = var.server_image
  server_type = var.server_type
  datacenter  = "nbg1-dc3"
  ssh_keys    = [hcloud_ssh_key.key.id]
  firewall_ids = [
    hcloud_firewall.firewall_general.id
  ]

  lifecycle {
    ignore_changes = [firewall_ids]
  }
}

resource "hcloud_firewall_attachment" "fw_all_k8s_nodes" {
  firewall_id = hcloud_firewall.firewall_all_k8s_nodes.id
  server_ids  = [for node in hcloud_server.nodes : node.id]
}

resource "hcloud_firewall_attachment" "fw_cp_access" {
  firewall_id = hcloud_firewall.k8s_cp_access.id
  server_ids  = [hcloud_server.nodes[0].id]
}

resource "hcloud_server_network" "nodes_network" {
  count      = var.node_count
  network_id = hcloud_network.my_net.id
  server_id  = element(hcloud_server.nodes.*.id, count.index)
  ip         = "10.0.1.${3 + count.index}"
}

# Use null_resource to wait for each server to be ready and run Ansible playbook
resource "null_resource" "run_ansible_playbook" {
  provisioner "local-exec" {
    command     = "until nc -zv ${hcloud_server.nodes[0].ipv4_address} 22; do echo 'Waiting for SSH to be available...'; sleep 20; done"
    working_dir = path.module
  }

  provisioner "local-exec" {
    command     = "IP='${join(",", hcloud_server.nodes[*].ipv4_address)}' SSH_USER=root make cluster-infra"
    working_dir = "${path.module}/.."
  }

  provisioner "local-exec" {
    command     = "IP='${hcloud_server.nodes[0].ipv4_address}' SSH_USER=root make cluster-control-plane adjust-kubeconfig"
    working_dir = "${path.module}/.."
  }

  provisioner "local-exec" {
    command     = "IP='${join(",", hcloud_server.nodes[*].ipv4_address)}' SSH_USER=root make setup-private-nodes"
    working_dir = "${path.module}/.."
  }

  provisioner "local-exec" {
    command     = "IP='${hcloud_server.nodes[0].ipv4_address}' SSH_USER=root make install-calico"
    working_dir = "${path.module}/.."
  }

  provisioner "local-exec" {
    command     = "IP='${join(",", slice(hcloud_server.nodes[*].ipv4_address, 1, length(hcloud_server.nodes[*].ipv4_address)))}' SSH_USER=root make cluster-join-nodes"
    working_dir = "${path.module}/.."
  }
}

output "node_ips" {
  value = hcloud_server.nodes[*].ipv4_address
}
