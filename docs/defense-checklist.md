# Defence checklist

- [ ] Show `app-forked` and `infra` GitHub repositories, PRs, conventional commits and tags.
- [ ] Show Terraform modules, MinIO state object and `terraform plan`.
- [ ] Show three EC2 nodes, EIP, least-privilege security groups and `ufw status`.
- [ ] Show multi-stage Dockerfile, Docker Hub SHA tag and named monitoring volumes.
- [ ] Push a feature branch: test/build/push executes and deployment does not.
- [ ] Merge to `main`: deploy, health check and SES email status execute.
- [ ] Show Jenkins CasC, built-in Docker CI node (`numExecutors > 0`), no Pi Jenkins agent.
- [ ] Show monitoring on Raspberry Pi: Grafana, Prometheus targets, Loki, Alertmanager.
- [ ] Show `kubectl get nodes`, StatefulSet replicas, Service, Ingress and PVCs.
- [ ] Open HTTPS endpoint and certificate details.
- [ ] Re-run Terraform and Ansible to prove idempotency.
- [ ] Show `.gitignore`, Ansible Vault and Jenkins Credentials; no secret appears in Git.
