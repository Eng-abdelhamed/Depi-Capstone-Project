# Security Checklist — Worker 4

Status legend: `[ ]` not done · `[x]` done · `[~]` partial / demo-acceptable shortcut

## 1. IAM & AWS Account
- [ ] No use of the AWS root account for daily work
- [ ] EKS node group IAM role has only the AWS-managed policies it needs
      (`AmazonEKSWorkerNodePolicy`, `AmazonEKS_CNI_Policy`, `AmazonEC2ContainerRegistryReadOnly`)
- [ ] No IAM user/role has `AdministratorAccess` unless it's a personal admin account
- [ ] `aws-auth` ConfigMap maps only the IAM principals that actually need cluster access
- [ ] GitHub Actions has no standing AWS credentials unless a workflow step genuinely needs AWS
      (e.g. `terraform apply`) - if it does, use OIDC federation (`aws-actions/configure-aws-credentials`
      with a GitHub OIDC provider) instead of long-lived access keys stored as secrets

## 2. Network / AWS
- [ ] EKS node security group only allows traffic from the cluster control plane and ALB
- [ ] No NAT Gateway created (cost rule) — confirm nodes reach the internet another way if required
- [ ] Only one ALB/ingress in use, not one per service
- [ ] Public IPv4 addresses limited to what's required (the ALB, mainly - there's no Jenkins EC2 anymore)

## 3. Kubernetes Cluster
- [ ] Namespaces separate frontend / backend / database / monitoring / argocd
- [ ] Every Deployment/StatefulSet sets `resources.requests` and `resources.limits`
- [ ] `default-deny-all` NetworkPolicy applied in every app namespace, plus explicit allows
      (see `security/network-policy.yaml`)
- [ ] RBAC follows least privilege — no ServiceAccount has cluster-admin unless it's Argo CD's own
      controller (see `security/rbac.yaml`)
- [ ] Containers run as non-root where the base image allows it:
      ```
      securityContext:
        runAsNonRoot: true
        runAsUser: 1000
        allowPrivilegeEscalation: false
      ```
- [ ] Liveness and readiness probes configured on frontend and backend
- [ ] No secret values committed in plaintext to the gitops repo — use Kubernetes Secrets
      (sealed/encrypted at rest by EKS) or a real secret manager for production

## 4. Secrets Management
- [ ] Docker Hub credentials stored as GitHub Actions **repository/organization secrets**, not in the workflow YAML
- [ ] MongoDB Atlas connection string stored as a Kubernetes Secret in the `backend` namespace, referenced by env var, never inline in a manifest or in the gitops repo in plaintext
- [ ] GitHub token used by the workflow to push to the gitops repo has the minimum scope needed (repo write only), stored as a repo secret, not a personal token pasted into YAML
- [ ] `.env` / secret files are in `.gitignore` in the application repo

## 4b. MongoDB Atlas
- [ ] Atlas Network Access List only allows the EKS node's public IP (or the VPC's egress CIDR) - not `0.0.0.0/0`, if avoidable within the free/shared tier's constraints
- [ ] Atlas database user is scoped to the specific database/collection the backend needs, not an Atlas admin user
- [ ] Connection uses `mongodb+srv://` with TLS (Atlas default) - don't disable TLS to "simplify" the demo
- [ ] Atlas project has its own alerting enabled (connections, CPU, disk) in the Atlas UI - this project's Prometheus stack does not see inside Atlas
- [ ] Atlas API keys (if Terraform/Atlas provider is used to provision the cluster) are stored as CI secrets, not committed

## 5. CI/CD Pipeline Gates (GitHub Actions)
- [ ] GitLeaks step fails the workflow on any detected secret
- [ ] SonarQube quality gate step fails the workflow below the agreed threshold
- [ ] Trivy step fails the workflow on CRITICAL (and ideally HIGH) vulnerabilities in the image
- [ ] Docker images are tagged with the commit SHA, not just `latest`, so rollback is possible
- [ ] The workflow's GitHub token/secret used to push to the gitops repo cannot also reach the Kubernetes cluster directly (CI stays outside the cluster's trust boundary; only Argo CD talks to the cluster)

## 6. Monitoring & Observability
- [ ] Prometheus running and scraping node, pod, and app-namespace metrics
- [ ] Grafana running with the three dashboards imported (cluster, application, CD pipeline)
- [ ] Alert rules loaded (`monitoring/alerts/basic-alert-rules.yaml`) and visible in Prometheus > Alerts
- [ ] Argo CD metrics being scraped (`argocd_app_info`, `argocd_app_sync_total`) - confirm with Worker 3 that Argo CD's Helm install has `metrics.enabled: true`
- [ ] Grafana admin password is not the default and not committed to git

## 7. Cost Control (cross-check against Section 4 of the plan)
- [ ] Single region, single EKS cluster, single managed node group
- [ ] Prometheus/Grafana/Alertmanager storage kept small (see `prometheus-values.yaml`)
- [ ] No extra Load Balancers created for monitoring — Grafana reached via the existing
      ingress-nginx LB at `/grafana` (see `monitoring/grafana-ingress.yaml`), not a new LB
- [ ] GitHub Actions minutes usage checked against the plan/org's free-tier limit (public repos are unlimited; private repos are metered)
- [ ] MongoDB Atlas is on the free (M0) or lowest shared tier unless there's a specific reason to pay for more
- [ ] Plan in place to `terraform destroy` after the final demo

## 8. Definition of Done (Worker 4 scope)
- [ ] Prometheus running
- [ ] Grafana running
- [ ] Dashboard shows node CPU, node memory, pod CPU, pod memory, pod restarts, application availability
- [ ] This security checklist fully reviewed with the team before the demo
