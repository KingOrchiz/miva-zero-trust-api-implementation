variable "project" { type = string }
variable "environment" { type = string }
variable "deployment_mode" { type = string }
variable "region" { type = string }
variable "existing_cce_cluster_id" { type = string }
variable "existing_vpc_id" { type = string }
variable "existing_subnet_id" { type = string }
variable "tags" { type = map(string) }
