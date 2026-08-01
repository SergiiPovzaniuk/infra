# Runbook

## Bootstrap

1. Create an AWS IAM principal limited to EC2, VPC, EIP and read-only AMI discovery.
2. Create an EC2 key pair and copy `terraform.tfvars.example` to `terraform.tfvars`.
3. Copy `backend.hcl.example` to `backend.hcl`; use the MinIO URL on the Jenkins host.
4. Export MinIO credentials as `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.
5. Copy `vault.yml.example` to `vault.yml`, replace placeholders, then encrypt it:

```bash
ansible-vault encrypt ansible/group_vars/all/vault.yml
```

6. Copy `hosts.ini.example` to `hosts.ini` (Jenkins = CI/MinIO, Raspberry Pi = monitoring).
7. Run `make local` for local hosts, then `make infra`, `make inventory`, `make configure`.

## Host map

| Host | Services |
|---|---|
| `192.168.1.80` | Jenkins `:8080`, MinIO `:9000/:9001`, node_exporter, promtail |
| `192.168.1.70` | Grafana `:3000`, Prometheus `:9090`, Alertmanager `:9093`, Loki `:3100`, node_exporter, promtail |

## DNS and TLS

Point the DuckDNS A record at `terraform -chdir=terraform/envs/prod output -raw app1_public_ip`. Set the same hostname in `app_domain`. Traefik requests a Let's Encrypt certificate after DNS propagation.

## Jenkins

Jenkins starts through `jenkins-compose.service` after reboot. Builds use the built-in node with Docker Pipeline (`numExecutors: 2`). The Raspberry Pi is not registered as a Jenkins agent.

Add `ansible/inventory/hosts.ini` as Jenkins secret-file credential `ansible-inventory`. Create a multibranch Pipeline for `app-forked/Jenkinsfile`, expose Jenkins with Cloudflare Tunnel, and set the GitHub webhook to `<public-jenkins-url>/github-webhook/`.

## Monitoring

Monitoring starts through `monitoring-compose.service` on the Pi after reboot.

- Grafana: `http://192.168.1.70:3000` (admin / value from vault `grafana_admin_password`)
- Prometheus: `http://192.168.1.70:9090`
- Loki push: `http://192.168.1.70:3100`

## SES notifications

1. Verify `SES_FROM` and `SES_TO` identities in SES.
2. Create SES SMTP credentials in the same region as `SES_SMTP_HOST`.
3. Set SES values in Jenkins `.env` / Ansible vault and recreate Jenkins.

## Recovery

| Symptom | Check | Action |
|---|---|---|
| Terraform lock remains | MinIO `tfstate` bucket | Confirm no apply runs; delete only the stale `.tflock` object |
| Jenkins down after reboot | `systemctl status jenkins-compose` | `cd /opt/jenkins && docker compose up -d` |
| Monitoring down after reboot | `systemctl status monitoring-compose` on Pi | `cd /opt/monitoring && docker compose up -d` |
| Prometheus target down | `http://192.168.1.70:9090/targets` | Check node_exporter container and UFW on the target host |
| No logs | `docker logs promtail` | Confirm Loki URL `192.168.1.70:3100` |

## Cost control

Create an AWS Budget alert before applying. Run `make destroy` after demonstrations.
