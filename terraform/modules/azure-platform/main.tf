locals {
  prefix              = "${var.project}-${var.environment}"
  create_dedicated    = var.deployment_mode == "dedicated-lab"
  resource_group_name = local.create_dedicated ? "rg-${local.prefix}" : var.existing_resource_group_name
}

resource "azurerm_resource_group" "this" {
  count    = local.create_dedicated ? 1 : 0
  name     = local.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "this" {
  count               = local.create_dedicated ? 1 : 0
  name                = "law-${local.prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this[0].name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_key_vault" "this" {
  count                       = local.create_dedicated ? 1 : 0
  name                        = substr(replace("kv-${local.prefix}", "-", ""), 0, 24)
  location                    = var.location
  resource_group_name         = azurerm_resource_group.this[0].name
  tenant_id                   = data.azurerm_client_config.current.tenant_id
  sku_name                    = "standard"
  purge_protection_enabled    = false
  soft_delete_retention_days  = 7
  enabled_for_deployment      = false
  enabled_for_disk_encryption = false
  tags                        = var.tags
}

data "azurerm_client_config" "current" {}

# AKS is intentionally not created yet. After Oche confirms the Azure dev/staging
# target, this module will either reference the existing AKS cluster or create a
# small dedicated cluster with strict cost controls.
