resource "azurerm_resource_group" "this" {
  name     = "rg-${var.project}-${var.environment}"
  location = var.location
  tags     = var.tags
}

# TODO: add VNet, AKS, Key Vault, Log Analytics, and container registry.
# Keep node count small for cost control.
