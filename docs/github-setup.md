# GitHub Flow

Repos: `SergiiPovzaniuk/infra` and `SergiiPovzaniuk/app-forked`.

## Model

Trunk-based **GitHub Flow**:

- `main` — always deployable
- short-lived `feature/*` branches
- merge only via Pull Request
- Conventional Commits: `feat:`, `fix:`, `ci:`, `docs:`, `chore:`

```text
main
 ├─ feature/repo-setup
 ├─ feature/terraform
 ├─ feature/ansible-base
 ├─ feature/jenkins-minio
 ├─ feature/monitoring
 ├─ feature/kubernetes
 └─ feature/docs
```

## Branch rules

1. `git checkout -b feature/<topic>`
2. Small commits, one concern each
3. Open PR → `main` (reference exam criterion in description)
4. Squash or merge commit; delete branch after merge
5. Tag milestones: `v0.1-terraform`, `v0.2-cicd`, `v1.0-exam`

## Never commit

Vault, inventory hosts, `host_vars`, `*.tfvars`, `.env`, private keys, kubeconfig, password helper scripts.

## Bootstrap

```bash
cd infra
git branch -M main
git remote add origin https://github.com/SergiiPovzaniuk/infra.git
git push -u origin main
```
