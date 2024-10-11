#vpc.tf output

output "VpcID" {
  description = "VPC Has Created"
  value       = aws_vpc.main.id
}

output "PublicRouteTable" {
  description = "Public Route Table Has Created"
  value       = aws_route_table.public_rt.id
}

output "PrivateRouteTable" {
  description = "Private Route Table Has Created"
  value       = aws_route_table.private_rt.id
}


#eks.tf
# output "eks_cluster_id" {
#   description = "The ID of the EKS cluster."
#   value       = aws_eks_cluster.eks_cluster.id
# }

# output "eks_node_group_id" {
#   description = "The ID of the EKS node group."
#   value       = aws_eks_node_group.eks_node_group.id
# }