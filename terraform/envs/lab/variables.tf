variable "project" {
  type        = string
  description = "Short project identifier used in resource names. For the prototype, use irestrict-v3."
  default     = "irestrict-v3"
}

variable "project_display_name" {
  type        = string
  description = "Human-readable product/prototype name for documentation and tags."
  default     = "iRestrict Version 3"
}

variable "environment" {
  type    = string
  default = "lab"
}

variable "deployment_mode" {
  type        = string
  description = "Deployment mode. For the MIVA/iRestrict v3 reproducible lab, only dedicated-lab is permitted."
  default     = "dedicated-lab"

  validation {
    condition     = var.deployment_mode == "dedicated-lab"
    error_message = "Only deployment_mode=dedicated-lab is permitted for the MIVA/iRestrict v3 reproducible lab. Existing enterprise/dev/staging clusters must not be targeted."
  }
}

variable "azure_location" {
  type        = string
  description = "Azure region for the dedicated lab. eastus is recommended for cost and availability unless changed."
  default     = "eastus"
}

variable "huawei_region" {
  type        = string
  description = "Huawei Cloud region for the dedicated lab. af-south-1 is recommended for proximity to West Africa."
  default     = "af-south-1"
}


variable "azure_create_resource_group" {
  type        = bool
  description = "Whether Terraform should create the Azure resource group. False when the RG is pre-created and delegated to Jane."
  default     = false
}

variable "azure_address_space" {
  type    = list(string)
  default = ["10.73.0.0/16"]
}

variable "azure_aks_subnet_prefixes" {
  type    = list(string)
  default = ["10.73.1.0/24"]
}

variable "azure_aks_node_count" {
  type        = number
  description = "Lean default node count for the dedicated AKS lab."
  default     = 1
}

variable "azure_aks_min_count" {
  type    = number
  default = 1
}

variable "azure_aks_max_count" {
  type    = number
  default = 2
}

variable "azure_aks_vm_size" {
  type        = string
  description = "Lean AKS node size. Standard_B2s is cheap; use Standard_B2ms if Keycloak/SPIRE need more memory."
  default     = "Standard_B2s"
}

variable "huawei_enterprise_project_id" {
  type        = string
  description = "Huawei Enterprise Project ID for iRestrict v3 lab resources."
  default     = "8842e64c-0771-48e5-b4de-dc5a95df99bd"
}

variable "huawei_vpc_cidr" {
  type    = string
  default = "10.83.0.0/16"
}

variable "huawei_subnet_cidr" {
  type    = string
  default = "10.83.1.0/24"
}

variable "huawei_subnet_gateway_ip" {
  type    = string
  default = "10.83.1.1"
}

variable "huawei_cluster_flavor_id" {
  type        = string
  description = "Huawei CCE cluster flavor. cce.s1.small is the lean dedicated-lab default. Confirm availability in the selected region before apply."
  default     = "cce.s1.small"
}

variable "huawei_node_flavor_id" {
  type        = string
  description = "Huawei ECS flavor for CCE worker nodes. Confirm regional availability before apply."
  default     = "s6.large.2"
}

variable "huawei_node_count" {
  type        = number
  description = "Huawei CCE worker node count. Default is 2 so managed add-on replicas can satisfy anti-affinity in the dedicated lab."
  default     = 2
}

variable "huawei_node_availability_zone" {
  type        = string
  description = "Huawei AZ for the worker node pool. Leave empty to let the provider/platform select where supported."
  default     = ""
}

variable "huawei_node_auth_mode" {
  type        = string
  description = "Huawei CCE worker authentication mode: key_pair or password. Use password if ECS keypair IAM permissions are blocked."
  default     = "key_pair"

  validation {
    condition     = contains(["key_pair", "password"], var.huawei_node_auth_mode)
    error_message = "huawei_node_auth_mode must be key_pair or password."
  }
}

variable "huawei_node_password" {
  type        = string
  description = "Temporary Huawei CCE worker password. Required only when huawei_node_auth_mode is password. Store only as a sensitive HCP Terraform variable."
  default     = ""
  sensitive   = true
}

variable "huawei_node_key_pair" {
  type        = string
  description = "Existing Huawei ECS key pair name for CCE worker access. Set in HCP Terraform if node pool creation requires it."
  default     = ""
}

variable "create_huawei_node_pool" {
  type        = bool
  description = "Create a minimal Huawei CCE node pool. Keep true for the full prototype after key pair/flavor are confirmed."
  default     = true
}

variable "azure_existing_resource_group_name" {
  type        = string
  description = "Pre-created Azure resource group for the dedicated lab. Also used by historical existing-clusters mode."
  default     = "Jane_Lab"
}

variable "azure_existing_aks_cluster_name" {
  type        = string
  description = "Existing AKS cluster for dev/staging mode. Not used in dedicated-lab mode."
  default     = ""
}

variable "huawei_existing_cce_cluster_id" {
  type        = string
  description = "Existing Huawei CCE cluster ID for dev/staging mode. Not used in dedicated-lab mode."
  default     = ""
}

variable "huawei_existing_vpc_id" {
  type        = string
  description = "Existing Huawei VPC ID for dev/staging mode. Not used in dedicated-lab mode."
  default     = ""
}

variable "huawei_existing_subnet_id" {
  type        = string
  description = "Existing Huawei subnet ID for dev/staging mode. Not used in dedicated-lab mode."
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
    project      = "irestrict-v3"
    product      = "iRestrict Version 3"
    environment  = "lab"
    owner        = "oche-eluma"
    purpose      = "academic-research"
    cost_profile = "lean"
  }
}
