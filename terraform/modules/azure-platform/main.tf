locals {
  prefix                       = "${var.project}-${var.environment}"
  compact_prefix               = substr(replace(local.prefix, "-", ""), 0, 18)
  create_dedicated             = var.deployment_mode == "dedicated-lab"
  resource_group_name          = local.create_dedicated ? "rg-${local.prefix}" : var.existing_resource_group_name
  aks_cluster_name             = local.create_dedicated ? "aks-${local.prefix}" : var.existing_aks_cluster_name
  container_registry_name      = substr("acr${local.compact_prefix}", 0, 50)
  log_analytics_workspace_name = "law-${local.prefix}"
}

data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "this" {
  count    = local.create_dedicated ? 1 : 0
  name     = local.resource_group_name
  location = var.location
  tags     = var.tags
}

resource "azurerm_log_analytics_workspace" "this" {
  count               = local.create_dedicated ? 1 : 0
  name                = local.log_analytics_workspace_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this[0].name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_virtual_network" "this" {
  count               = local.create_dedicated ? 1 : 0
  name                = "vnet-${local.prefix}"
  location            = var.location
  resource_group_name = azurerm_resource_group.this[0].name
  address_space       = var.address_space
  tags                = var.tags
}

resource "azurerm_subnet" "aks" {
  count                = local.create_dedicated ? 1 : 0
  name                 = "snet-aks-${local.prefix}"
  resource_group_name  = azurerm_resource_group.this[0].name
  virtual_network_name = azurerm_virtual_network.this[0].name
  address_prefixes     = var.aks_subnet_prefixes
}

resource "azurerm_container_registry" "this" {
  count               = local.create_dedicated ? 1 : 0
  name                = local.container_registry_name
  resource_group_name = azurerm_resource_group.this[0].name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.tags
}

resource "azurerm_key_vault" "this" {
  count                      = local.create_dedicated ? 1 : 0
  name                       = substr(replace("kv-${local.prefix}", "-", ""), 0, 24)
  location                   = var.location
  resource_group_name        = azurerm_resource_group.this[0].name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  purge_protection_enabled   = false
  soft_delete_retention_days = 7
  tags                       = var.tags
}

resource "azurerm_kubernetes_cluster" "this" {
  count               = local.create_dedicated ? 1 : 0
  name                = local.aks_cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.this[0].name
  dns_prefix          = replace(local.prefix, "_", "-")

  default_node_pool {
    name                 = "system"
    vm_size              = var.aks_vm_size
    node_count           = var.aks_node_count
    enable_auto_scaling = true
    min_count            = var.aks_min_count
    max_count            = var.aks_max_count
    vnet_subnet_id       = azurerm_subnet.aks[0].id
    os_disk_size_gb      = 64
  }

  identity {
    type = "SystemAssigned"
  }

  oidc_issuer_enabled               = true
  workload_identity_enabled         = true
  role_based_access_control_enabled = true
  local_account_disabled            = false
  sku_tier                          = "Free"

  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.this[0].id
  }

  network_profile {
    network_plugin    = "azure"
    load_balancer_sku = "standard"
  }

  tags = var.tags
}
