# Architecture decisions

## Host roles

| Host | Role |
|---|---|
| Jenkins server `192.168.1.80` | Jenkins controller, Docker-based CI builds, MinIO Terraform state |
| Raspberry Pi `192.168.1.70` | Monitoring plane: Prometheus, Grafana, Alertmanager, Loki |
| EC2 app-1/2/3 | k3s application cluster |

The Raspberry Pi is not a Jenkins agent. CI uses Docker agents on the Jenkins controller (`amd64`). The Pi only scrapes/exports observability data and hosts the monitoring stack.

## Three-node k3s

`app1` runs the control plane and public Traefik ingress. `app2` and `app3` are workers. A StatefulSet has two replicas and one PVC per replica. The public security group attaches only to `app1`; all nodes share a private cluster security group.

## Terraform and MinIO

Terraform state is remote because it is infrastructure data, not source code. The S3 backend speaks to local MinIO on the Jenkins host. Credentials come from environment variables and never enter Git.

## Terraform versus Ansible

Terraform provisions AWS resources. Ansible configures operating systems and services. Repeating either command converges to the desired state.

## Observability path

`node_exporter` and `promtail` run on Jenkins, the Pi, and later EC2 nodes. Logs ship to Loki on the Pi (`192.168.1.70:3100`). Prometheus on the Pi scrapes all exporters. Grafana and Alertmanager also run on the Pi.

## Delivery

Every branch runs tests and publishes an immutable Docker image tagged with the Git SHA. Only `main` deploys.
