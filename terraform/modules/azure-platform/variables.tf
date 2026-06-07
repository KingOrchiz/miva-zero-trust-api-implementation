variable "project" { type = string }
variable "environment" { type = string }
variable "deployment_mode" { type = string }
variable "location" { type = string }
variable "existing_resource_group_name" { type = string }
variable "existing_aks_cluster_name" { type = string }
variable "tags" { type = map(string) }
