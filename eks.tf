#
# EKS Cluster Resources
#  * IAM Role to allow EKS service to manage other AWS services
#  * EC2 Security Group to allow networking traffic with EKS cluster
#  * EKS Cluster
#

resource "aws_iam_role" "secil" {
  name = "terraform-eks-secil"

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
}

resource "aws_iam_role_policy_attachment" "secil-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.secil.name
}

resource "aws_iam_role_policy_attachment" "secil-AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.secil.name
}

resource "aws_security_group" "secil" {
  name        = "terraform-eks-secil"
  description = "Cluster communication with worker nodes"
  vpc_id      = "vpc-3e2xxx" #aws_vpc.demo.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform-eks-demo"
  }
}

resource "aws_security_group_rule" "secil-ingress-workstation-https" {
 # cidr_blocks       = [local.workstation-external-cidr]
  cidr_blocks = ["0.0.0.0/0"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.secil.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_eks_cluster" "demo" {
  name     = var.cluster-name
  role_arn = aws_iam_role.secil.arn

  vpc_config {
    security_group_ids = [aws_security_group.secil.id]
    subnet_ids         =  ["subnet-d0sdfsdf","subnet-5efxxx"]
  }

  depends_on = [
    aws_iam_role_policy_attachment.secil-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.secil-AmazonEKSVPCResourceController,
  ]
}
