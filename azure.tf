locals {
  resource_group_name = "${var.resource_group_name}-${var.environment}"
  aks_name            = "${var.aks_name}-${var.environment}"
}

resource "azurerm_resource_group" "rg" {
  name     = local.resource_group_name
  location = var.location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = local.aks_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = local.aks_name

  default_node_pool {
    name = "default"
    # vm_size              = "Standard_B2ms"
    vm_size              = "standard_ds2_v2"
    auto_scaling_enabled = true
    min_count            = 3
    max_count            = 6
    zones                = ["1", "2", "3"]
  }

  identity {
    type = "SystemAssigned"
  }
  storage_profile {
    disk_driver_enabled = true
    file_driver_enabled = true
  }
}
