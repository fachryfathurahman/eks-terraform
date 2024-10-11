variable "region" {
  description = "Region of AWS"
  type        = string
}

variable "cluster_name" {
  description = "Name of Cluster"
  type = string
  default = "eks-cluster"
}

variable "aws_account_id" {
  type        = string
  description = "AWS Account ID"
}

variable "eks_worker_node_role_name" {
  type        = string
  description = "EKS Worker Node IAM Role Name"
  default     = "eks-worker-node-role"
}
