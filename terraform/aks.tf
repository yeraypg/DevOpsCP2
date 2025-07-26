variable "aks_name" {
  type        = string
  description = "Nombre del AKS"
  default     = "aks-cp2"
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = var.aks_name
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  dns_prefix          = "${var.aks_name}-dns"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  network_profile {
    network_plugin = "azure"
  }

  tags = {
    environment = "casopractico2"
  }
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

output "kubeconfig" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}
