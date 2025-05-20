# Variable values for Azure deployment
# Customize these values as needed

prefix                   = "aznetwork"
location                 = "East US"
environment              = "dev"
owner                    = "terraform-user"
project_name             = "network-infrastructure"
vnet_address_space       = "10.0.0.0/16"
subnet1_address_prefix   = "10.0.1.0/24"
subnet2_address_prefix   = "10.0.2.0/24"
enable_service_endpoints = true
admin_cidr_block         = "10.0.0.0/24" # Restricted IP range for administrative access

# AKS Configuration
aks_node_size           = "Standard_D2s_v3"
aks_node_count          = 3
aks_min_node_count      = 3
aks_max_node_count      = 5
aks_enable_auto_scaling = true
aks_enable_logging      = true

# Application Gateway Configuration
appgw_subnet_address_prefix = "10.0.3.0/24"
enable_app_gateway          = true
