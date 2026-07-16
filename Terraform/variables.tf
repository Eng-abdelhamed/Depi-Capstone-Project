variable "aws_region" { default = "us-east-1" }
variable "environment" { default = "dev" }
variable "vpc_cidr" { default = "10.0.0.0/16" }
variable "public_subnets" { default = ["10.0.1.0/24", "10.0.2.0/24"] }
variable "private_subnets" { default = ["10.0.3.0/24", "10.0.4.0/24"] }
variable "azs" { default = ["us-east-1a", "us-east-1b"] }
variable "cluster_name" { default = "my-modular-cluster" }
variable "node_instance_types" { default = ["t3.medium"] }