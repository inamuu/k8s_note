
module "eks" {
  source                         = "terraform-aws-modules/eks/aws"
  version                        = "~> 20.0"
  cluster_name                   = local.cluster_name
  cluster_version                = "1.31"
  cluster_endpoint_public_access = true

  cluster_enabled_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

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
      max_size     = 3
      desired_size = 1
    }
  }

  enable_cluster_creator_admin_permissions = true

  tags = {
    Environment                                 = "dev"
    Terraform                                   = "true"
    "kubernetes.io/cluster/dev-dev-eks-1b03569" = "owned"
    "karpenter.sh/discovery"                    = "karpenter"
  }
}
