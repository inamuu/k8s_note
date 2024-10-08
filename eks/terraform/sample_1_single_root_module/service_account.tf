################################################################################
# Service Account                                                              #
################################################################################
resource "kubernetes_service_account" "awsloadbalancercontroller" {
  metadata {
    namespace = "kube-system"
    name      = "aws-load-balancer-controller"

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.aws_loadbalancer_controller.arn
    }
  }
}
