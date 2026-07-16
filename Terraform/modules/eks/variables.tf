variable "cluster_name" { type = string }
variable "environment" { type = string }
variable "vpc_id" { type = string }
variable "private_subnet_ids" { type = list(string) }
variable "public_subnet_ids" { type = list(string) }
variable "node_instance_types" { type = list(string) }
variable "node_desired_size" { type = number }
variable "node_max_size" { type = number }
variable "node_min_size" { type = number }
variable "aws_region" {
  description = "AWS Region"
  type        = string
  default     = "us-east-1"
}