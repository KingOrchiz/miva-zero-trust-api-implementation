terraform {
  required_version = ">= 1.6.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.117"
    }
    huaweicloud = {
      source  = "huaweicloud/huaweicloud"
      version = "~> 1.92"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.33"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.16"
    }
  }
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = false
    }
  }
}

provider "huaweicloud" {
  region = var.huawei_region
}

# Kubernetes and Helm providers are intentionally left without connection
# configuration for now. They will be enabled only after Oche confirms whether
# the deployment target is a dedicated lab cluster or existing dev/staging
# AKS/CCE clusters.
provider "kubernetes" {}
provider "helm" {
  kubernetes {}
}
