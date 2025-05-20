# Terraform configuration for Azure resources
# This deploys a new resource group, virtual network, two subnets, and an AKS cluster

# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = ">= 3.1"
    }
  }
  required_version = ">= 1.0.0"
}

provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}-rg"
  location = var.location

  tags = merge(var.tags, {
    Environment = var.environment
    Owner       = var.owner
    Project     = var.project_name
  })
}

# Create a virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.prefix}-vnet"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  address_space       = [var.vnet_address_space]

  tags = merge(var.tags, {
    Environment = var.environment
    Owner       = var.owner
    Project     = var.project_name
  })
}

# Create the first subnet
resource "azurerm_subnet" "subnet1" {
  name                 = "${var.prefix}-subnet1"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet1_address_prefix]

  # Optional: Configure service endpoints for enhanced security
  service_endpoints = var.enable_service_endpoints ? ["Microsoft.Storage", "Microsoft.KeyVault"] : []
}

# Create the second subnet
resource "azurerm_subnet" "subnet2" {
  name                 = "${var.prefix}-subnet2"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnet2_address_prefix]

  # Optional: Configure service endpoints for enhanced security
  service_endpoints = var.enable_service_endpoints ? ["Microsoft.Storage", "Microsoft.KeyVault"] : []
}

# Create a dedicated subnet for Application Gateway
resource "azurerm_subnet" "appgw_subnet" {
  name                 = "${var.prefix}-appgw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.appgw_subnet_address_prefix]
}

# Optional: Create Network Security Group for subnet1
resource "azurerm_network_security_group" "subnet1_nsg" {
  name                = "${var.prefix}-subnet1-nsg"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  # Example security rule - modify according to your requirements
  security_rule {
    name                       = "AllowSSH"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = var.admin_cidr_block
    destination_address_prefix = "*"
  }

  tags = merge(var.tags, {
    Environment = var.environment
    Owner       = var.owner
    Project     = var.project_name
  })
}

# Associate NSG with subnet1
resource "azurerm_subnet_network_security_group_association" "subnet1_nsg_association" {
  subnet_id                 = azurerm_subnet.subnet1.id
  network_security_group_id = azurerm_network_security_group.subnet1_nsg.id
}

# Create a public IP for the Application Gateway
resource "azurerm_public_ip" "appgw_pip" {
  name                = "${var.prefix}-appgw-pip"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  allocation_method   = "Static"
  sku                 = "Standard"

  tags = merge(var.tags, {
    Environment = var.environment
    Owner       = var.owner
    Project     = var.project_name
  })
}

# Deploy AKS Cluster
# tfsec:ignore:azure-container-limit-authorized-ips
module "aks" {
  source  = "Azure/aks/azurerm"
  version = "7.5.0"

  resource_group_name = azurerm_resource_group.rg.name
  kubernetes_version  = var.kubernetes_version
  prefix              = var.prefix
  cluster_name        = "${var.prefix}-aks"
  location            = azurerm_resource_group.rg.location

  # Network settings
  vnet_subnet_id = azurerm_subnet.subnet1.id
  network_plugin = "azure"
  network_policy = "azure"

  # Node pool configuration
  agents_size         = var.aks_node_size
  agents_count        = var.aks_node_count
  agents_min_count    = var.aks_min_node_count
  agents_max_count    = var.aks_max_node_count
  enable_auto_scaling = var.aks_enable_auto_scaling
  # System settings
  rbac_aad                          = true
  role_based_access_control_enabled = true
  private_cluster_enabled           = false
  api_server_authorized_ip_ranges   = [var.admin_cidr_block]

  # Add-ons
  log_analytics_workspace_enabled = var.aks_enable_logging

  # Identity settings
  identity_type = "SystemAssigned"
  # Application Gateway Ingress Controller settings
  ingress_application_gateway_enabled   = true
  ingress_application_gateway_subnet_id = azurerm_subnet.appgw_subnet.id
  ingress_application_gateway_name      = "${var.prefix}-appgw"

  # Tags
  tags = merge(var.tags, {
    Environment = var.environment
    Owner       = var.owner
    Project     = var.project_name
  })
}
