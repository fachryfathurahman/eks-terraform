locals {
  AzA = "${var.region}a"
  AzB = "${var.region}b"
  AzC = "${var.region}c"
}

variable "VpcBlock" {
  description = "IPv4 Block for VPC"
  type        = string
  default     = "172.21.0.0/16" #TODO change cidr vpc
}

variable "PublicBlockA" {
  description = "IPv4 CIDR Public Subnet Availability Zone A"
  type        = string
  default     = "172.21.1.0/24" #TODO change cidr public subnet A
}

variable "PublicBlockB" {
  description = "IPv4 CIDR Public Subnet Availability Zone B"
  type        = string
  default     = "172.21.2.0/24" #TODO change cidr public subnet B
}

variable "PublicBlockC" {
  description = "IPv4 CIDR Public Subnet Availability Zone C"
  type        = string
  default     = "172.21.3.0/24" #TODO change cidr public subnet C
}

variable "PrivateBlockA" {
  description = "IPv4 CIDR EC2 Availability Zone A"
  type        = string
  default     = "172.21.4.0/24" #TODO change cidr private subnet A
}

variable "PrivateBlockB" {
  description = "IPv4 CIDR EC2 Availability Zone B"
  type        = string
  default     = "172.21.5.0/24" #TODO change cidr private subnet 
}

variable "PrivateBlockC" {
  description = "IPv4 CIDR EC2 Availability Zone C"
  type        = string
  default     = "172.21.6.0/24" #TODO change cidr private subnet 
}


variable "ProjectName" {
  description = "Project Name"
  type        = string
  default     = "IDX Project" 
}

variable "ProjectDate" {
  description = "Project Implementation Date"
  type        = string
  default     = "17/08/2024"
}

variable "VpcName" {
  description = "VPC Name"
  type        = string
  default     = "VPC-EKS-IDX" #
}


resource "aws_vpc" "main" {
  cidr_block           = var.VpcBlock
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name     = var.VpcName
    Date     = var.ProjectDate
    Project  = var.ProjectName
    Creator  = "Terraform"
    Resource = "VPC"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name     = "IGW-${var.VpcName}"
    Project  = var.ProjectName
    Date     = var.ProjectDate
    Creator  = "Terraform"
    Resource = "Internet Gateway"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {

  tags = {
    Name     = "NAT-EIP-${var.VpcName}"
    Project  = var.ProjectName
    Date     = var.ProjectDate
    Creator  = "Terraform"
    Resource = "Elastic IP"
  }
}

# NAT Gateway
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_a.id

  tags = {
    Name     = "NAT-GW-${var.VpcName}"
    Project  = var.ProjectName
    Date     = var.ProjectDate
    Creator  = "Terraform"
    Resource = "NAT Gateway"
  }
}

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.AzA
  cidr_block              = var.PublicBlockA
  map_public_ip_on_launch = true

  tags = {
    Name                      = "PUBLIC-A-${var.VpcName}"
    Project                   = var.ProjectName
    Date                      = var.ProjectDate
    Creator                   = "Terraform"
    Resource                  = "Subnet"
    "kubernetes.io/role/elb"        = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.AzB
  cidr_block              = var.PublicBlockB
  map_public_ip_on_launch = true

  tags = {
    Name     = "PUBLIC-B-${var.VpcName}"
    Project  = var.ProjectName
    Date     = var.ProjectDate
    Creator  = "Terraform"
    Resource = "Subnet"
    "kubernetes.io/role/elb"        = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "public_c" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.AzC
  cidr_block              = var.PublicBlockC
  map_public_ip_on_launch = true

  tags = {
    Name     = "PUBLIC-C-${var.VpcName}"
    Project  = var.ProjectName
    Date     = var.ProjectDate
    Creator  = "Terraform"
    Resource = "Subnet"
    "kubernetes.io/role/elb"        = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "private_a" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.AzA
  cidr_block              = var.PrivateBlockA
  map_public_ip_on_launch = false

  tags = {
    Name     = "PRIVATE-A-${var.VpcName}"
    Project  = var.ProjectName
    Date     = var.ProjectDate
    Creator  = "Terraform"
    Resource = "Subnet"
    "kubernetes.io/role/internal-elb"        = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "private_b" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.AzB
  cidr_block              = var.PrivateBlockB
  map_public_ip_on_launch = false

  tags = {
    Name     = "PRIVATE-B-${var.VpcName}"
    Project  = var.ProjectName
    Date     = var.ProjectDate
    Creator  = "Terraform"
    Resource = "Subnet"
    "kubernetes.io/role/internal-elb"        = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

resource "aws_subnet" "private_c" {
  vpc_id                  = aws_vpc.main.id
  availability_zone       = local.AzC
  cidr_block              = var.PrivateBlockC
  map_public_ip_on_launch = false

  tags = {
    Name     = "PRIVATE-C-${var.VpcName}"
    Project  = var.ProjectName
    Date     = var.ProjectDate
    Creator  = "Terraform"
    Resource = "Subnet"
    "kubernetes.io/role/internal-elb"        = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}


resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name     = "PUBLIC-RT-${var.VpcName}"
    Project  = var.ProjectName
    Date     = var.ProjectDate
    Creator  = "Terraform"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name     = "PRIVATE-RT-${var.VpcName}"
    Project  = var.ProjectName
    Date     = var.ProjectDate
    Creator  = "Terraform"
  }
}


resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "private_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gw.id
}

resource "aws_route_table_association" "public_assoc_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_c" {
  subnet_id      = aws_subnet.public_c.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_assoc_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_c" {
  subnet_id      = aws_subnet.private_c.id
  route_table_id = aws_route_table.private_rt.id
}