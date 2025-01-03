module "karpenter" {
  source       = "terraform-aws-modules/eks/aws//modules/karpenter"
  cluster_name = module.eks.cluster_name

  # irsa
  enable_irsa                     = true
  irsa_namespace_service_accounts = ["kube-system:karpenter"]
  irsa_oidc_provider_arn          = module.eks.oidc_provider_arn
  #create_node_iam_role = false
  #node_iam_role_arn    = module.eks.eks_managed_node_groups["node01"].iam_role_arn

  # iam policy name
  iam_policy_name            = "KarpenterController"
  iam_policy_use_name_prefix = false

  # controller iam role name
  iam_role_name            = "KarpenterController"
  iam_role_use_name_prefix = false

  # node iam role name
  node_iam_role_name            = "KarpenterNode"
  node_iam_role_use_name_prefix = false

  # Attach additional IAM policies to the Karpenter node IAM role
  node_iam_role_additional_policies = {
    AmazonSSMManagedInstanceCore = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }

  # Since the node group role will already have an access entry
  create_access_entry = false
  tags = {
    Environment                    = "dev"
    Terraform                      = "true"
    "app.kubernetes.io/managed-by" = "Helm"
  }
}

resource "kubernetes_service_account" "karpenter" {

  metadata {
    name      = "karpenter"
    namespace = "kube-system"

    #"eks.amazonaws.com/role-arn"     = module.karpenter_irsa.iam_role_arn
    annotations = {
      "eks.amazonaws.com/role-arn"     = module.karpenter.iam_role_arn
      "meta.helm.sh/release-name"      = "karpenter"
      "meta.helm.sh/release-namespace" = "kube-system"
    }

    labels = {
      "app.kubernetes.io/managed-by" = "Helm"
    }
  }
}

resource "aws_security_group" "karpenter_node" {
  name        = "karpernter-node"
  description = "karpernter node security group"
  vpc_id      = var.vpc_id

  tags = {
    "karpenter.sh/discovery" = "karpenter"
  }
}
