variable "node_group_name" {
  description = "The name of the EKS node group."
  type        = string
  default     = "eks-nodegroup"
}

variable "node_instance_type" {
  description = "EC2 instance type for the nodes."
  type        = string
  default     = "t3.medium" #TODO change instance type
}

variable "node_instance_storage" {
  description = "EC2 instance Storage for the nodes."
  type        = number
  default     = 30
}

variable "ami_instance_type" {
  description = "AMI instance type for the nodes."
  type        = string
  default     = "AL2_x86_64"
}

variable "key_name" {
  description = "The name of the SSH key pair to access the nodes."
  type        = string
  default     = "keypair-nodegroup"
}

variable "desired_capacity" {
  description = "The desired number of nodes."
  type        = number
  default     = 1
}

variable "max_size" {
  description = "The maximum number of nodes."
  type        = number
  default     = 3
}

variable "min_size" {
  description = "The minimum number of nodes."
  type        = number
  default     = 1
}

variable "version_eks" {
  description = "Kubernetes version for the EKS cluster."
  type        = string
  default     = "1.30"
}

variable "ami_id" {
  description = "Image ID Worker Node"
  type = string
  default = "ami-060573ecd3943c6ff"
  
}
# resource "aws_key_pair" "deployer" {
#   key_name   = "deployer-key"
#   public_key = file("deployer-key.pub")
# }

resource "aws_iam_role" "eks_cluster_role" {
  name = "${var.cluster_name}-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  ]
}

resource "aws_iam_role" "node_instance_role" {
  name = var.eks_worker_node_role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  ]
}
resource "aws_launch_template" "eks_launch_template" {
  name_prefix = "eks-launch-template"
  image_id    = var.ami_id

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size = var.node_instance_storage
      encrypted   = true
      kms_key_id  = aws_kms_key.eks_ebs_encryption.arn
    }
  }
  user_data = base64encode(<<-EOF
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="==MYBOUNDARY=="
--==MYBOUNDARY==
Content-Type: text/x-shellscript; charset="us-ascii"
#!/bin/bash
/etc/eks/bootstrap.sh eks-cluster
--==MYBOUNDARY==--\
  EOF
  )
}

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.public_a.id,aws_subnet.public_b.id]
  }

  version = var.version_eks
  tags = {
    "alpha.eksctl.io/cluster-oidc-enabled" = true
    "k8s.io/cluster-autoscaler/enabled" = true
    "k8s.io/cluster-autoscaler/${var.cluster_name}" = "owned"
  }
}

resource "aws_eks_node_group" "eks_node_group" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.node_instance_role.arn
  subnet_ids      = [aws_subnet.public_a.id]

  launch_template {
    id      = aws_launch_template.eks_launch_template.id
    version = "$Latest"
    # version = 1
  }
  scaling_config {
    desired_size = var.desired_capacity
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = [var.node_instance_type]
  # disk_size      = var.node_instance_storage
  # ami_type       = var.ami_instance_type

  # remote_access {
  #   ec2_ssh_key = aws_key_pair.deployer.id
  # }
}


