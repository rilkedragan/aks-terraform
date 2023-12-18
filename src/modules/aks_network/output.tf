output "aks_subnet_id" {
  value = azurerm_subnet.aks_subnet[0].id
}
output "ingress_subnet_id" {
  value = azurerm_subnet.ingress_subnet[0].id
}
output "aks_vnet_id" {
  value = azurerm_virtual_network.aks_vnet.id
}

