resource "azurerm_kubernetes_cluster" "cluster" {
  name                = var.cluster_name
  location            = var.location
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version

  default_node_pool {
    name            = var.default_pool_name
    node_count      = var.node_count
    vm_size         = var.vm_size
    os_disk_size_gb = var.os_disk_size_gb
    vnet_subnet_id  = var.vnet_subnet_id
    max_pods        = var.max_pods
    type            = var.default_pool_type

    enable_auto_scaling = true
    min_count           = var.min_count
    max_count           = var.max_count
    
    tags = merge(
    {
       "environment" = "runitoncloud"
    },
    {
      "aadssh" = "True"
    },
  )
  }

   azure_active_directory_role_based_access_control {
    managed                = true
    admin_group_object_ids = var.aks_admin_group_object_ids
    azure_rbac_enabled     = true
  }

  network_profile {
    network_plugin     = var.network_plugin
    network_policy     = "calico"
    service_cidr       = var.service_cidr
    dns_service_ip     = "10.0.0.10"
    
  }
  ingress_application_gateway {
    
    subnet_id = var.ingress_subnet_id
  }
  identity {
     type = "SystemAssigned"
  }
  
 tags = {
        Environment = "Development"
    }
  
  
  lifecycle {
    prevent_destroy = false
  }
}

resource "azurerm_monitor_diagnostic_setting" "aks_cluster" {
  name                       = "${azurerm_kubernetes_cluster.cluster.name}-audit"
  target_resource_id         = azurerm_kubernetes_cluster.cluster.id
  log_analytics_workspace_id = var.diagnostics_workspace_id
  log_analytics_destination_type = "Dedicated"

  log {
    category = "kube-apiserver"
    enabled  = true
  }

  log {
    category = "kube-controller-manager"
    enabled  = true
  }

  log {
    category = "cluster-autoscaler"
    enabled  = true
  }

  log {
    category = "kube-scheduler"
    enabled  = true
  }

  log {
    category = "kube-audit"
    enabled  = true
  }

  metric {
    category = "AllMetrics"
    enabled  = false
  }
}


##########################################################
#               Azure Container Registry                 #
##########################################################
# A Kubernetes cluster is not complete without a         #
# container registry.                                    #

resource "azurerm_container_registry" "acr" {
  name                     = var.acr_name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  sku                      = "Standard"
}


##########################################################
#         K8s Service Principle role assignment          #
##########################################################
# Below role assignments gives the "Network Contributor" #
# role to the AKS Service Principle to eg. read public   #
# IP resources and a role for the AKS cluster to be able #
# to pull images from the ACR.                           #

resource "azurerm_role_assignment" "role1" {
  scope                = var.main_rg_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.cluster.identity[0].principal_id
}


resource "azurerm_role_assignment" "role2" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.cluster.kubelet_identity[0].object_id
}


resource "azurerm_role_assignment" "aks_subnet_role_assignment" {
  scope                = var.ingress_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.cluster.identity[0].principal_id
}

resource "azurerm_role_assignment" "node_subnet_role_assignment" {
  scope                = var.vnet_subnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_kubernetes_cluster.cluster.identity[0].principal_id
}