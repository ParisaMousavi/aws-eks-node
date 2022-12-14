resource "aws_eks_node_group" "this" {
  # Ensure that IAM Role permissions are created before and deleted after EKS Node Group handling.
  # Otherwise, EKS will not be able to properly delete EC2 Instances and Elastic Network Interfaces.
  depends_on = [
    aws_iam_role_policy_attachment.this_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.this_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.this_AmazonEC2ContainerRegistryReadOnly,
  ]
  cluster_name    = var.cluster_name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.this.arn
  subnet_ids      = var.subnet_ids
  instance_types  = var.instance_types
  disk_size       = var.disk_size
  scaling_config {
    desired_size = var.scaling_config.desired_size
    max_size     = var.scaling_config.max_size
    min_size     = var.scaling_config.min_size
  }
  update_config {
    max_unavailable = 1
  }
  tags = merge(
    var.additional_tags,
    {
      created-by = "iac-tf"
    },
  )
  # Optional: Allow external changes without Terraform plan difference
  # lifecycle {
  #   ignore_changes = [scaling_config[0].desired_size]
  # }
}

resource "aws_iam_role" "this" {
  name               = "${var.node_group_name}-worker-role"
  description        = "Allows EC2 instances to call AWS services on your behalf."
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
}

resource "aws_iam_role_policy_attachment" "this_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "this_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.this.name
}

resource "aws_iam_role_policy_attachment" "this_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.this.name
}
