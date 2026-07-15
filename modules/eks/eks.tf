resource "aws_iam_role" "eks_cluster_role" {
  name = "eks-cluster-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "eks.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster_role.name
}

resource "aws_eks_cluster" "main" {
  name     = "django-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = var.subnet_ids
  }
  depends_on = [aws_iam_role_policy_attachment.eks_cluster_policy]
}

resource "aws_iam_role" "eks_nodes_role" {
  name = "eks-node-group-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{ Action = "sts:AssumeRole", Effect = "Allow", Principal = { Service = "ec2.amazonaws.com" } }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes_role.name
}
resource "aws_iam_role_policy_attachment" "eks_cni" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes_role.name
}
resource "aws_iam_role_policy_attachment" "ecr_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes_role.name
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "django-node-group"
  node_role_arn   = aws_iam_role.eks_nodes_role.arn
  subnet_ids      = var.subnet_ids

  scaling_config {
    desired_size = 1
    max_size     = 1
    min_size     = 1
  }

  instance_types = ["t3.small"]

  depends_on = [
    aws_iam_role_policy_attachment.eks_worker_node,
    aws_iam_role_policy_attachment.eks_cni,
    aws_iam_role_policy_attachment.ecr_readonly,
  ]
}

# resource "aws_iam_role_policy_attachment" "eks_ebs_csi" {
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
#   role       = aws_iam_role.eks_nodes_role.name
# }
#
#
#
# resource "aws_eks_addon" "ebs_csi" {
#   cluster_name = aws_eks_cluster.main.name
#   addon_name   = "aws-ebs-csi-driver"
#
#   configuration_values = jsonencode({
#     controller = {
#       nodeSelector = {}
#     }
#   })
#
#   resolve_conflicts_on_create = "OVERWRITE"
#   resolve_conflicts_on_update = "OVERWRITE"
#
#   depends_on = [
#     aws_eks_node_group.nodes,
#     aws_iam_role_policy_attachment.eks_ebs_csi
#   ]
