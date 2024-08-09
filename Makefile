include .env
export $(shell sed 's/=.*//' .env)

define tf
	terraform -chdir=terraform $(1) $(2) -var="hcloud_token=$(HCLOUD_TOKEN)"
endef

plan:
	$(call tf,plan)

apply:
	$(call tf,apply,-auto-approve)

destroy:
	$(call tf,destroy,-auto-approve)

SSH_USER?=root
IP?=$(shell terraform -chdir=terraform output -json node_ips | jq -j '.[0]')
IP1?=$(shell terraform -chdir=terraform output -json node_ips | jq -j '.[1]')
IP2?=$(shell terraform -chdir=terraform output -json node_ips | jq -j '.[2]')
define run-playbook
	ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook ansible/$(1) -i $(IP), -u $(SSH_USER) --private-key ~/.ssh/id_rsa
endef

cluster-infra:
	$(call run-playbook,enable-i-pv4-packet-forwarding.yml)
	$(call run-playbook,install-containerd-and-runc.yml)
	$(call run-playbook,install-cni-plugins.yml)
	$(call run-playbook,create-containerd-config.yml)
	$(call run-playbook,prepare-kubeadm.yml)

cluster-control-plane:
	$(call run-playbook,init-control-plane.yml)
	$(call run-playbook,download-kube-config.yml)
	mv ansible/config ~/.kube/config
	chmod 600 ~/.kube/config

adjust-kubeconfig:
	# since the cluster is private and the control plane ip in the private network we need to do this
	$(shell sed -i '' 's*https://10.0.1.3*https://'$(IP)'*' ~/.kube/config)

setup-private-nodes:
	$(call run-playbook,setup-private-nodes.yml)

install-calico:
	$(call run-playbook,install-calico.yml)
	sleep 70

cluster-join-nodes:
	$(call run-playbook,join-nodes.yml)
	echo mark workers on control plane node if you want to

output:
	terraform -chdir=terraform output
