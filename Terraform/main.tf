terraform {

  backend "s3" {
    bucket = "apolloos3back"
    key    = "eks-infra/terraform.tfstate"
    region = "us-east-1"
    # use_lockfile = true
    # encrypt      = true
  }
  required_version = ">= 1.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.9"
    }
  }
}


module "vpc" {
  source = "./modules/network"

  environment          = var.environment
  vpc_cidr             = var.vpc_cidr
  public_subnets_cidr  = var.public_subnets
  private_subnets_cidr = var.private_subnets
  azs                  = var.azs
}

module "eks" {
  source = "./modules/eks"

  cluster_name        = var.cluster_name
  environment         = var.environment
  vpc_id              = module.vpc.vpc_id
  public_subnet_ids   = module.vpc.public_subnet_ids
  private_subnet_ids  = module.vpc.private_subnet_ids
  node_instance_types = var.node_instance_types

  node_desired_size = 2
  node_max_size     = 3
  node_min_size     = 1
}
resource "aws_eks_access_entry" "mazen" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = "arn:aws:iam::797601397904:user/Mazen"
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "mazen_admin" {
  cluster_name  = aws_eks_cluster.main.name
  principal_arn = aws_eks_access_entry.mazen.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}
