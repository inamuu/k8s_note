resource "aws_eks_cluster" "cluster" {
  name                      = local.cluster_name
  enabled_cluster_log_types = ["api", "audit"]
  role_arn                  = aws_iam_role.cluster.arn
  upgrade_policy {
    support_type = "STANDARD"
  }

  vpc_config {
    subnet_ids = [
      var.subnet_ids["private-1a"],
      var.subnet_ids["private-1c"],
    ]
    public_access_cidrs = var.public_access_cidrs
    # cluster_security_group_id は自分で設定することができない(自動生成される)
    # https://qiita.com/neruneruo/items/f043370ceca855547bdf
  }

  # Ensure that IAM Role permissions are created before and deleted after EKS Cluster handling.
  # Otherwise, EKS will not be able to properly delete EKS managed EC2 infrastructure such as Security Groups.
  depends_on = [
    aws_cloudwatch_log_group.cluster,
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
  ]
}

output "endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "kubeconfig-certificate-authority-data" {
  value = aws_eks_cluster.cluster.certificate_authority[0].data
}

## security group for EKS cluster
#resource "aws_security_group" "eks_cluster" {
#  vpc_id = var.vpc_id
#  name   = local.cluster_name
#}
#
#resource "aws_vpc_security_group_ingress_rule" "cluster_ingress" {
#  security_group_id            = aws_security_group.eks_cluster.id
#  referenced_security_group_id = aws_security_group.eks_cluster.id
#  from_port                    = "-1"
#  to_port                      = "-1"
#  ip_protocol                  = "-1"
#}
#
#resource "aws_vpc_security_group_egress_rule" "cluster_egress" {
#  security_group_id = aws_security_group.eks_cluster.id
#  cidr_ipv4         = "0.0.0.0/0"
#  from_port         = "-1"
#  to_port           = "-1"
#  ip_protocol       = "-1"
#}
