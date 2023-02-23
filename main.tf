resource "aws_eks_cluster" "eks_control" {
  name     = var.eks_cluster_name
  role_arn = aws_iam_role.control_plane_role.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = var.subnet_ids
    endpoint_private_access = "true"
    endpoint_public_access  = "false"
    security_group_ids      = [aws_security_group.api-sg.id]
  }

  encryption_config {
    resources = ["secrets"]

    provider {
      key_arn = var.kms_key_arn
    }
  }

  #TODO add dependson for aws_cloudwatch_log_group? Mostly just ensures naming, i think
  enabled_cluster_log_types = [
    "api",
    "audit",
    "authenticator",
    "controllerManager",
    "scheduler",
  ]

  depends_on = [
    aws_iam_role_policy_attachment.control_plane_role_attachment
  ]

  tags = var.tags
}

resource "aws_iam_role" "control_plane_role" {
  name_prefix          = var.eks_cluster_name
  assume_role_policy   = data.aws_iam_policy_document.assume_role_policy.json
  permissions_boundary = var.permissions_boundary

  tags = merge(
    var.tags,
    {
      compliance-app = ""
    },
  )
}

resource "aws_iam_role_policy_attachment" "control_plane_role_attachment" {
  role       = aws_iam_role.control_plane_role.name
  policy_arn = "arn:${data.aws_partition.current.partition}:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_security_group_rule" "cluster_shared_node_443" {
  description       = "Allow kubernetes api access (port 443) from CG network"
  security_group_id = aws_eks_cluster.eks_control.vpc_config.0.cluster_security_group_id
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8"]
}

# Create additional SG and add the rule to it. Then make the cluster depend on
# it. This is to force the SG rule to remain until after the cluster is gone.
# This dependency is required to make sure that Helm is able to clean up
# properly.
resource "aws_security_group" "api-sg" {
  name_prefix = var.eks_cluster_name
  vpc_id      = data.aws_subnet.subnet_zero.vpc_id
  description = "Allow Kubernetes API access (port 443) from CG network"

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/8"]
  }

  tags = var.tags
}

# Enable IAM Roles for Service Accounts
#resource "aws_iam_openid_connect_provider" "irsa" {
#  client_id_list  = ["sts.amazonaws.com"]
#  thumbprint_list = []
#  url             = aws_eks_cluster.eks_control.identity.0.oidc.0.issuer
#}

resource "aws_servicecatalog_provisioned_product" "irsa" {
  count = var.deploy_oidc_provider ? 1 : 0

  name                       = "oidc-${var.eks_cluster_name}"
  product_name               = "OIDC Provider for EKS cluster"
  provisioning_artifact_name = var.oidc_sc_version
  tags                       = var.tags

  provisioning_parameters {
    key   = "EKSClusterName"
    value = var.eks_cluster_name
  }

  depends_on = [
    aws_eks_cluster.eks_control
  ]
}

#VPC-CNI add-on install
# resource "aws_eks_addon" "vpc_cni" {
#   cluster_name      = aws_eks_cluster.eks_control.name
#   addon_name        = "vpc-cni"
#   resolve_conflicts = var.vpc_cni_resolve_conflicts
#   addon_version     = var.vpc_cni_addon_version

# }


resource "aws_eks_addon" "kube-proxy" {
  depends_on   = [aws_eks_node_group.node-group-1]
  cluster_name = aws_eks_cluster.eks_control.name
  addon_name   = "kube-proxy"
}

resource "aws_eks_addon" "coredns" {
  depends_on   = [aws_eks_node_group.node-group-1]
  cluster_name = aws_eks_cluster.eks_control.name
  addon_name   = "coredns"
}

###############################################
# Data
###############################################
data "aws_partition" "current" {}

data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

data "aws_subnet" "subnet_zero" {
  id = var.subnet_ids[0]
}
# vim: sw=2 ts=2 et
