data "tls_certificate" "cluster" {
  url = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "this" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.cluster.identity[0].oidc[0].issuer
}


resource "aws_iam_role" "aws_loadbalancer_controller" {
  name               = "${local.cluster_name}-aws-loadbalancer-controller"
  assume_role_policy = data.aws_iam_policy_document.aws_loadbalancer_controller_assume_policy.json

  tags = {
    "alpha.eksctl.io/cluster-name"                = aws_eks_cluster.cluster.name
    "eksctl.cluster.k8s.io/v1alpha1/cluster-name" = aws_eks_cluster.cluster.name
    "alpha.eksctl.io/iamserviceaccount-name"      = "kube-system/aws-load-balancer-controller"
  }
}

data "aws_iam_policy_document" "aws_loadbalancer_controller_assume_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:aws-load-balancer-controller"]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.this.url, "https://", "")}:aud"
      values   = ["sts.amazonaws.com"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.this.arn]
      type        = "Federated"
    }
  }
}
