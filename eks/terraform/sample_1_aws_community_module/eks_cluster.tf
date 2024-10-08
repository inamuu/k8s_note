
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.cluster_name
  cluster_version = "1.31"

  cluster_endpoint_public_access = true

  cluster_addons = {
    coredns                = {}
    eks-pod-identity-agent = {}
    kube-proxy             = {}
    vpc-cni                = {}
  }

  vpc_id = var.vpc_id
  subnet_ids = [
    var.subnet_ids["private-1a"],
    var.subnet_ids["private-1c"],
  ]
  # EKS Managed Node Group(s)
  eks_managed_node_group_defaults = {
    instance_types = ["t4g.medium"]
    disk_size      = 20
    subnet_ids = [
      var.subnet_ids["private-1a"],
      var.subnet_ids["private-1c"],
    ]
  }

  eks_managed_node_groups = {
    node01 = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      ami_type = "AL2023_ARM_64_STANDARD"

      min_size     = 1
      max_size     = 1
      desired_size = 1
    }
  }

  # Cluster access entry
  # To add the current caller identity as an administrator
  # NOTE: https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/security_iam_troubleshoot.html#security-iam-troubleshoot-cannot-view-nodes-or-workloads
  enable_cluster_creator_admin_permissions = true

  #access_entries = {
  #  # One access entry with a policy associated
  #  example = {
  #    kubernetes_groups = []
  #    principal_arn     = "arn:aws:iam::123456789012:role/something"

  #    policy_associations = {
  #      example = {
  #        policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  #        access_scope = {
  #          namespaces = ["default"]
  #          type       = "namespace"
  #        }
  #      }
  #    }
  #  }
  #}

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}
