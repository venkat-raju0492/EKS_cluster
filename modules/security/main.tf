# Cluster security ----------------------------------------------------------------------------
resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.project}-eks-cluster-role-${var.env}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = "${merge(var.common_tags, map(
    "Name", "${var.project}-eks-cluster-role-${var.env}"
  ))}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = "${aws_iam_role.eks_cluster_role.name}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_AmazonEKSServicePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = "${aws_iam_role.eks_cluster_role.name}"
}

resource "aws_security_group" "eks_cluster_sg" {
  name        = "${var.project}-eks-cluster-sg-${var.env}"
  description = "Cluster communication with worker nodes"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = "${merge(var.common_tags, map(
    "Name", "${var.project}-eks-cluster-sg-${var.env}"
  ))}"
}

resource "aws_security_group_rule" "eks_cluster_ingress_https" {
  cidr_blocks       = "${var.public_cidr}"
  description       = "Allow local network to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = "${aws_security_group.eks_cluster_sg.id}"
  to_port           = 443
  type              = "ingress"
}

#Service LB--------------------------------------------------------------------------------
resource "aws_security_group" "eks_cluster_service_elb_sg" {
  name        = "${var.project}-eks-cluster-service-elb-sg-${var.env}"
  description = "LB sg used for eks service LB"
  vpc_id      = "${var.vpc_id}"

  ingress {
    description = "Allow HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = "${var.public_cidr}"
  }

  ingress {
    description = "Allow HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = "${var.public_cidr}"
  }

  ingress {
    description = "Destination Unreachable: fragmentation required, and DF flag set"
    from_port   = "3"
    to_port     = "4"
    protocol    = "icmp"
    cidr_blocks = "${var.public_cidr}"
  }

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  tags = "${merge(var.common_tags, map(
    "Name", "${var.project}-eks-cluster-service-elb-sg-${var.env}",
    "kubernetes.io/cluster/${var.cluster_name}", "owned"
  ))}"
}

# Nodes security ----------------------------------------------------------------------------
resource "aws_iam_role" "eks_cluster_nodes_role" {
  name = "${var.project}-eks-cluster-nodes-role-${var.env}"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY

  tags = "${merge(var.common_tags, map(
    "Name", "${var.project}-eks-cluster-nodes-role-${var.env}"
  ))}"

}

resource "aws_iam_policy" "eks_cluster_nodes_policy_dynamodb" {
  name = "${var.project}-eks-cluster-nodes-eks_cluster_nodes_policy_dynamodb-policy-${var.env}"
  path        = "/"
  description = "${var.project}-eks-cluster-nodes-eks_cluster_nodes_policy_dynamodb-policy-${var.env}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "dynamodb:ListTables",
                "dynamodb:DescribeContributorInsights",
                "dynamodb:ListTagsOfResource",
                "dynamodb:DescribeReservedCapacityOfferings",
                "dynamodb:DescribeTable",
                "dynamodb:GetItem",
                "dynamodb:DescribeContinuousBackups",
                "dynamodb:DescribeLimits",
                "dynamodb:BatchGetItem",
                "dynamodb:ConditionCheckItem",
                "dynamodb:ListBackups",
                "dynamodb:Scan",
                "dynamodb:Query",
                "dynamodb:DescribeStream",
                "dynamodb:DescribeTimeToLive",
                "dynamodb:ListStreams",
                "dynamodb:ListContributorInsights",
                "dynamodb:DescribeGlobalTableSettings",
                "dynamodb:ListGlobalTables",
                "dynamodb:GetShardIterator",
                "dynamodb:DescribeGlobalTable",
                "dynamodb:DescribeReservedCapacity",
                "dynamodb:DescribeBackup",
                "dynamodb:GetRecords",
                "dynamodb:DescribeTableReplicaAutoScaling"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "eks_cluster_nodes_policy_podautoscalling" {
  name = "${var.project}-eks-cluster-nodes-podautoscalling-policy-${var.env}"
  path        = "/"
  description = "${var.project}-eks-cluster-nodes-podautoscalling-policy-${var.env}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "autoscaling:DescribeAutoScalingGroups",
                "autoscaling:DescribeAutoScalingInstances",
                "autoscaling:SetDesiredCapacity",
                "autoscaling:TerminateInstanceInAutoScalingGroup",
                "autoscaling:DescribeTags"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_policy" "eks_cluster_nodes_policy_ingresscontroller" {
  name = "${var.project}-eks-cluster-nodes-ingresscontroller-policy-${var.env}"
  path        = "/"
  description = "${var.project}-eks-cluster-nodes-ingresscontroller-policy-${var.env}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "acm:DescribeCertificate",
                "acm:ListCertificates",
                "acm:GetCertificate"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:AuthorizeSecurityGroupIngress",
                "ec2:CreateSecurityGroup",
                "ec2:CreateTags",
                "ec2:DeleteTags",
                "ec2:DeleteSecurityGroup",
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAddresses",
                "ec2:DescribeInstances",
                "ec2:DescribeInstanceStatus",
                "ec2:DescribeInternetGateways",
                "ec2:DescribeNetworkInterfaces",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeTags",
                "ec2:DescribeVpcs",
                "ec2:ModifyInstanceAttribute",
                "ec2:ModifyNetworkInterfaceAttribute",
                "ec2:RevokeSecurityGroupIngress"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:AddListenerCertificates",
                "elasticloadbalancing:AddTags",
                "elasticloadbalancing:CreateListener",
                "elasticloadbalancing:CreateLoadBalancer",
                "elasticloadbalancing:CreateRule",
                "elasticloadbalancing:CreateTargetGroup",
                "elasticloadbalancing:DeleteListener",
                "elasticloadbalancing:DeleteLoadBalancer",
                "elasticloadbalancing:DeleteRule",
                "elasticloadbalancing:DeleteTargetGroup",
                "elasticloadbalancing:DeregisterTargets",
                "elasticloadbalancing:DescribeListenerCertificates",
                "elasticloadbalancing:DescribeListeners",
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeLoadBalancerAttributes",
                "elasticloadbalancing:DescribeRules",
                "elasticloadbalancing:DescribeSSLPolicies",
                "elasticloadbalancing:DescribeTags",
                "elasticloadbalancing:DescribeTargetGroups",
                "elasticloadbalancing:DescribeTargetGroupAttributes",
                "elasticloadbalancing:DescribeTargetHealth",
                "elasticloadbalancing:ModifyListener",
                "elasticloadbalancing:ModifyLoadBalancerAttributes",
                "elasticloadbalancing:ModifyRule",
                "elasticloadbalancing:ModifyTargetGroup",
                "elasticloadbalancing:ModifyTargetGroupAttributes",
                "elasticloadbalancing:RegisterTargets",
                "elasticloadbalancing:RemoveListenerCertificates",
                "elasticloadbalancing:RemoveTags",
                "elasticloadbalancing:SetIpAddressType",
                "elasticloadbalancing:SetSecurityGroups",
                "elasticloadbalancing:SetSubnets",
                "elasticloadbalancing:SetWebACL"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "iam:CreateServiceLinkedRole",
                "iam:GetServerCertificate",
                "iam:ListServerCertificates"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "cognito-idp:DescribeUserPoolClient"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "waf-regional:GetWebACLForResource",
                "waf-regional:GetWebACL",
                "waf-regional:AssociateWebACL",
                "waf-regional:DisassociateWebACL"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "tag:GetResources",
                "tag:TagResources"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "waf:GetWebACL"
            ],
            "Resource": "*"
        }
    ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "eks_cluster_nodes_role_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = "${aws_iam_role.eks_cluster_nodes_role.name}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_nodes_role_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = "${aws_iam_role.eks_cluster_nodes_role.name}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_nodes_role_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = "${aws_iam_role.eks_cluster_nodes_role.name}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_nodes_role_ingresscontroller" {
  policy_arn = "${aws_iam_policy.eks_cluster_nodes_policy_ingresscontroller.arn}"
  role       = "${aws_iam_role.eks_cluster_nodes_role.name}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_nodes_role_podautoscalling" {
  policy_arn = "${aws_iam_policy.eks_cluster_nodes_policy_podautoscalling.arn}"
  role       = "${aws_iam_role.eks_cluster_nodes_role.name}"
}

resource "aws_iam_role_policy_attachment" "eks_cluster_nodes_role_dynamodb" {
  policy_arn = "${aws_iam_policy.eks_cluster_nodes_policy_dynamodb.arn}"
  role       = "${aws_iam_role.eks_cluster_nodes_role.name}"
}
