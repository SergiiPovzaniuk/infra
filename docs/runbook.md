# Runbook

## Bootstrap (one-time host prep)

1. AWS IAM with EC2, VPC, EIP, ELB/NLB; EC2 key pair `exam-devops`.
2. Copy key to Jenkins host: `/opt/jenkins/ssh/exam-devops.pem` (`chmod 600`).
3. Fill `ansible/group_vars/all/vault.yml` (AWS, MinIO, Docker Hub, GitHub, SES).
4. `make local` once (Jenkins + MinIO + CasC).

## Deploy (Jenkins only)

1. Push `infra` and `app-forked` to GitHub.
2. Run **`infra/main`** with `ACTION=apply`, `DEPLOY_APP=true`.
   - Terraform (NLB + 3× EC2) → Ansible k3s → kubeconfig/ingress_ip → triggers **`app-forked/main`**.
3. Tear down: **`infra/main`** with `ACTION=destroy`.

## Host map

| Host | Services |
|---|---|
| `192.168.1.80` | Jenkins `:8080`, MinIO `:9000/:9001`, node_exporter, promtail |
| `192.168.1.70` | Grafana `:3000`, Prometheus `:9090`, Alertmanager `:9093`, Loki `:3100`, node_exporter, promtail |

## Ingress (NLB EIP)

Terraform creates a Network Load Balancer with one Elastic IP in front of all three k3s nodes (ports 80/443 → Traefik). No DuckDNS/ACME.

```bash
terraform -chdir=terraform/envs/prod output -raw lb_public_ip
./scripts/sync-jenkins-ingress.sh   # writes /opt/jenkins/ingress_ip for Jenkins CD
```

Reach the app at `http://<lb_public_ip>/`. Jenkins Deploy curls that IP after rollout.

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
