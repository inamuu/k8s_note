module "karpenter" {
  source = "terraform-aws-modules/eks/aws//modules/karpenter"

  cluster_name = module.eks.cluster_name

  create_node_iam_role = false
  node_iam_role_arn    = module.eks.eks_managed_node_groups["node01"].iam_role_arn

  # Since the node group role will already have an access entry
  create_access_entry = false
  tags = {
    Environment = "dev"
    Terraform   = "true"
  }
}

# Karpenter IRSA
# https://registry.terraform.io/modules/terraform-aws-modules/iam/aws/latest/submodules/iam-role-for-service-accounts-eks
# https://qiita.com/okubot55/items/15119dac01229a25bd93
module "karpenter_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                          = "karpenter_controller"
  attach_karpenter_controller_policy = true

  karpenter_controller_cluster_name       = local.cluster_name
  karpenter_controller_node_iam_role_arns = [module.eks.eks_managed_node_groups["node01"].iam_role_arn]

  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }
}

resource "kubernetes_namespace" "karpenter" {
  metadata {
    name = "karpenter"
  }
}

resource "kubernetes_service_account" "karpenter" {
  metadata {
    name      = "karpenter"
    namespace = "karpenter"

    annotations = {
      "eks.amazonaws.com/role-arn"     = module.karpenter_irsa.iam_role_arn
      "meta.helm.sh/release-name"      = "karpenter"
      "meta.helm.sh/release-namespace" = "karpenter"
      "app.kubernetes.io/managed-by"   = "Helm"
    }
  }
}

resource "aws_iam_instance_profile" "karpenter" {
  name = "${local.cluster_name}-KarpenterNodeInstanceProfile"
  role = module.eks.eks_managed_node_groups["node01"].iam_role_name
}

