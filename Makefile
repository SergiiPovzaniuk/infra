.PHONY: minio-ready infra inventory configure local verify destroy jenkins-agent

TF_DIR := terraform/envs/prod

minio-ready:
	ansible-galaxy collection install -r ansible/requirements.yml
	ansible-playbook -i ansible/inventory/hosts.ini ansible/minio.yml

local:
	ansible-galaxy collection install -r ansible/requirements.yml
	ansible-playbook -i ansible/inventory/hosts.ini ansible/local.yml

infra:
	terraform -chdir=$(TF_DIR) init -backend-config=backend.hcl
	terraform -chdir=$(TF_DIR) apply
	./scripts/sync-jenkins-ingress.sh

inventory:
	./scripts/generate-inventory.sh
	./scripts/sync-jenkins-ingress.sh

configure:
	ansible-galaxy collection install -r ansible/requirements.yml
	ansible-playbook -i ansible/inventory/hosts.ini ansible/site.yml

verify:
	ansible k3s_server -i ansible/inventory/hosts.ini -m command -a "kubectl get nodes"
	curl --fail http://$$(terraform -chdir=$(TF_DIR) output -raw lb_public_ip)/

destroy:
	terraform -chdir=$(TF_DIR) destroy

jenkins-agent:
	docker build -t exam-jenkins-agent:latest jenkins/agent
