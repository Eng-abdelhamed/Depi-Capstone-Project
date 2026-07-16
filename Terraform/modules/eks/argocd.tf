resource "aws_iam_role" "argo_updater" {
  name = "${var.cluster_name}-argo-updater"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "argo_updater_ecr" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.argo_updater.name
}

resource "aws_eks_pod_identity_association" "argo_updater" {
  cluster_name    = aws_eks_cluster.main.name
  namespace       = "argocd"
  service_account = "argo-image-updater"
  role_arn        = aws_iam_role.argo_updater.arn
}


# ---------------------------------------------------------------------------
# 1. INSTALL ARGOCD (The Engine)
# ---------------------------------------------------------------------------

# We use "argocd_v2" to force Terraform to treat this as a new resource
# and break any "stuck" state from previous failed attempts.
resource "helm_release" "argocd_v2" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.7.0"

  # 1. Set Type to LoadBalancer (AWS will default to Classic LB)
  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  # 2. Run in insecure mode (HTTP)
  # This avoids TLS issues since we don't have a domain certificate yet
  set {
    name  = "server.extraArgs"
    value = "{--insecure}"
  }

  # 3. Connection Draining (Standard for Classic LB)
  set {
    name  = "server.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-connection-draining-enabled"
    value = "true"
  }

  depends_on = [
    aws_eks_cluster.main,
    aws_eks_node_group.main,
    aws_eks_access_policy_association.admin
  ]
}

# ---------------------------------------------------------------------------
# 2. INSTALL ARGO IMAGE UPDATER (The Automation)
# ---------------------------------------------------------------------------

resource "helm_release" "updater" {
  name       = "argo-image-updater"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-image-updater" # Correct Chart Name
  namespace  = "argocd"
  version    = "0.9.1" # Stable Version

  # --- Service Account (Linked to IAM Role for ECR Access) ---
  set {
    name  = "serviceAccount.create"
    value = "true"
  }
  set {
    name  = "serviceAccount.name"
    value = "argo-image-updater"
  }

  # --- ECR Registry Configuration ---
  set {
    name  = "config.registries[0].name"
    value = "ECR"
  }
  set {
    name  = "config.registries[0].api_url"
    value = "https://${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  }
  set {
    name  = "config.registries[0].prefix"
    value = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com"
  }
  set {
    name  = "config.registries[0].ping"
    value = "true"
  }
  set {
    name  = "config.registries[0].credentials"
    value = "ext:/scripts/ecr-login.sh"
  }
  set {
    name  = "config.registries[0].credsexpire"
    value = "10h"
  }

  # --- FIX FOR CRASH LOOP ---
  # Since ArgoCD is running with --insecure (HTTP), the updater
  # must connect via plaintext. Do NOT set 'insecure=true' here.

  set {
    name  = "config.argocd.plaintext"
    value = "true"
  }

  set {
    name  = "config.argocd.serverAddress"
    value = "argocd-server.argocd.svc:80"
  }

  depends_on = [
    helm_release.argocd_v2,
    aws_eks_pod_identity_association.argo_updater
  ]
}
