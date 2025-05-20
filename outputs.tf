# Output values for Azure resources

output "resource_group_id" {
  description = "ID of the created resource group"
  value       = azurerm_resource_group.rg.id
}

output "resource_group_name" {
  description = "Name of the created resource group"
  value       = azurerm_resource_group.rg.name
}

output "virtual_network_id" {
  description = "ID of the created virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output "virtual_network_name" {
  description = "Name of the created virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output "subnet1_id" {
  description = "ID of the first subnet"
  value       = azurerm_subnet.subnet1.id
}

output "subnet2_id" {
  description = "ID of the second subnet"
  value       = azurerm_subnet.subnet2.id
}

output "subnet1_cidr" {
  description = "Address range of the first subnet"
  value       = var.subnet1_address_prefix
}

output "subnet2_cidr" {
  description = "Address range of the second subnet"
  value       = var.subnet2_address_prefix
}

# AKS Outputs
output "aks_id" {
  description = "ID of the AKS cluster"
  value       = module.aks.aks_id
}

output "aks_name" {
  description = "Name of the AKS cluster"
  value       = module.aks.aks_name
}

output "aks_fqdn" {
  description = "FQDN of the AKS cluster"
  value       = module.aks.cluster_fqdn
}

output "aks_node_resource_group" {
  description = "Auto-generated resource group for AKS nodes"
  value       = module.aks.node_resource_group
}

output "aks_kube_config_raw" {
  description = "Raw kubectl configuration for the AKS cluster"
  value       = module.aks.kube_config_raw
  sensitive   = true
}

# Application Gateway outputs
output "app_gateway_name" {
  description = "Name of the Application Gateway"
  value       = module.aks.ingress_application_gateway != null ? module.aks.ingress_application_gateway.gateway_name : null
}

output "app_gateway_public_ip" {
  description = "Public IP address of the Application Gateway"
  value       = azurerm_public_ip.appgw_pip.ip_address
}

output "app_gateway_url" {
  description = "URL of the Application Gateway"
  value       = "http://${azurerm_public_ip.appgw_pip.ip_address}"
}

output "azure_portal_url" {
  description = "URL to view resources in Azure Portal"
  value       = "https://portal.azure.com/#@/resource${azurerm_resource_group.rg.id}"
}
