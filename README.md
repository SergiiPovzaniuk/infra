# Hybrid DevOps Infrastructure

```text
MinIO (Jenkins host) -> Terraform -> AWS: k3s server + 2 workers
GitHub -> Cloudflare Tunnel -> Jenkins (CI/CD) -> Docker Hub -> k3s
Jenkins + Pi + EC2 exporters -> Raspberry Pi (Prometheus/Grafana/Loki/Alertmanager)
```

| Host | Role |
|---|---|
| Jenkins `192.168.1.80` | Jenkins, Docker CI, MinIO |
| Raspberry Pi `192.168.1.70` | Monitoring stack only |
| EC2 x3 | Application k3s cluster |

## Prerequisites

- Terraform >= 1.10
- Ansible >= 2.16
- AWS CLI credentials for EC2/VPC/EIP
- MinIO endpoint/keys as `AWS_ACCESS_KEY_ID` / `AWS_SECRET_ACCESS_KEY`
- Docker Hub, SES, DuckDNS values in Jenkins/Ansible Vault

## Usage

```bash
cp terraform/envs/prod/terraform.tfvars.example terraform/envs/prod/terraform.tfvars
cp terraform/envs/prod/backend.hcl.example terraform/envs/prod/backend.hcl
cp ansible/inventory/hosts.ini.example ansible/inventory/hosts.ini
make local
make infra
make inventory
make configure
make verify
```

## Documentation

- [Architecture](docs/architecture.md)
- [Runbook](docs/runbook.md)
- [Defence checklist](docs/defense-checklist.md)
- [GitHub setup](docs/github-setup.md)
