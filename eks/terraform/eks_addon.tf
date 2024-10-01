# AWSコンソールでクラスター作成時にデフォルトで追加されるアドオン
locals {
  addon_names = [
    "vpc-cni",
    "kube-proxy",
    "coredns",
  ]
}

resource "aws_eks_addon" "cluster" {
  for_each     = toset(local.addon_names)
  cluster_name = aws_eks_cluster.cluster.name
  addon_name   = each.key
}
