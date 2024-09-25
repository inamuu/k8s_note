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

resource "aws_iam_policy" "alb_ingress_controller" {
  name   = "${local.cluster_name}-aws-loadbalancer-controller"
  policy = file("${path.module}/files/alb-ingress-iam-policy.json")
}

# Helm(AWS Load Balancer Controller)
# 参考ページ: https://qiita.com/neruneruo/items/f043370ceca855547bdf#helm%E3%81%A7aws-load-balancer-controller%E3%82%92%E8%B5%B7%E5%8B%95%E3%81%99%E3%82%8B
# Helmで直接実行: https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/lbc-helm.html
resource "helm_release" "aws_load_balancer_controller" {
  depends_on = [kubernetes_service_account.awsloadbalancercontroller]

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"

  wait_for_jobs = true

  set {
    name  = "clusterName" // EKSのクラスタ名
    value = aws_eks_cluster.cluster.name
  }
  set {
    name  = "region" // EKSクラスタを起動しているリージョン
    value = var.region
  }
  set {
    name  = "vpcId" // EKSクラスタを起動しているVPCのVPC-ID
    value = var.vpc_id
  }
  set {
    name  = "serviceAccount.create" // ServiceAccountを自動で作成するか
    value = false
  }
  set {
    name  = "serviceAccount.name" // 前節で作成したServiceAccountと合わせる
    value = "aws-load-balancer-controller"
  }
  set {
    name  = "ingressClassParams.create" // IngressClassを自動で作るか
    value = false
  }
  set {
    name  = "createIngressClassResource" // IngressClassを自動で作るか
    value = false
  }
}
