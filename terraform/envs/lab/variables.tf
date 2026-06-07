variable "project" {
  type    = string
  default = "miva-zt-api-auth"
}

variable "environment" {
  type    = string
  default = "lab"
}

variable "deployment_mode" {
  type        = string
  description = "Deployment mode: dedicated-lab or existing-clusters."
  default     = "existing-clusters"

  validation {
    condition     = contains(["dedicated-lab", "existing-clusters"], var.deployment_mode)
    error_message = "deployment_mode must be dedicated-lab or existing-clusters."
  }
}

variable "azure_location" {
  type    = string
  default = "westeurope"
}

variable "huawei_region" {
  type    = string
  default = "af-south-1"
}

variable "azure_existing_resource_group_name" {
  type        = string
  description = "Existing Azure resource group for dev/staging mode."
  default     = ""
}

variable "azure_existing_aks_cluster_name" {
  type        = string
  description = "Existing AKS cluster for dev/staging mode."
  default     = ""
}

variable "huawei_existing_cce_cluster_id" {
  type        = string
  description = "Existing Huawei CCE cluster ID for dev/staging mode."
  default     = ""
}

variable "huawei_existing_vpc_id" {
  type        = string
  description = "Existing Huawei VPC ID for dev/staging mode."
  default     = ""
}

variable "huawei_existing_subnet_id" {
  type        = string
  description = "Existing Huawei subnet ID for dev/staging mode."
  default     = ""
}

variable "enable_azure_platform" {
  type    = bool
  default = true
}

variable "enable_huawei_platform" {
  type    = bool
  default = true
}

variable "enable_kubernetes_bootstrap" {
  type    = bool
  default = false
}

variable "tags" {
  type = map(string)
  default = {
    project     = "miva-zt-api-auth"
    environment = "lab"
    owner       = "oche-eluma"
    purpose     = "academic-research"
  }
}
