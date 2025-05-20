# Variables for Azure resources

variable "prefix" {
  description = "Prefix for naming resources"
  type        = string
  default     = "terraproj"
}

variable "location" {
  description = "Azure region where resources will be deployed"
  type        = string
  default     = "East US"
}

variable "environment" {
  description = "Environment tag (e.g., dev, test, prod)"
  type        = string
  default     = "dev"
}

variable "owner" {
  description = "Owner tag for resources"
  type        = string
  default     = "terraform"
}

variable "project_name" {
  description = "Project name tag for resources"
  type        = string
  default     = "terraform-network-demo"
}

variable "tags" {
  description = "A map of tags to apply to all resources"
  type        = map(string)
  default = {
    Environment = "dev"
    Owner       = "terraform"
    Project     = "terraform-network-demo"
    ManagedBy   = "terraform"
  }
}

variable "vnet_address_space" {
  description = "Address space for the virtual network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "subnet1_address_prefix" {
  description = "Address prefix for the first subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet2_address_prefix" {
  description = "Address prefix for the second subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "enable_service_endpoints" {
  description = "Enable service endpoints on subnets"
  type        = bool
  default     = true
}

variable "admin_cidr_block" {
  description = "CIDR block for admin access"
  type        = string
  default     = "0.0.0.0/0" # Note: For production, restrict this to specific IP ranges
}

# AKS Variables
variable "kubernetes_version" {
  description = "Kubernetes version to use for the AKS cluster"
  type        = string
  default     = null # Will use the latest version available in the region
}

variable "aks_node_size" {
  description = "Size of the AKS worker nodes"
  type        = string
  default     = "Standard_D2s_v3"
}

variable "aks_node_count" {
  description = "Initial number of nodes in AKS cluster"
  type        = number
  default     = 3
}

variable "aks_min_node_count" {
  description = "Minimum number of nodes for the AKS cluster autoscaling"
  type        = number
  default     = 3
}

variable "aks_max_node_count" {
  description = "Maximum number of nodes for the AKS cluster autoscaling"
  type        = number
  default     = 5
}

variable "aks_enable_auto_scaling" {
  description = "Enable node pool autoscaling"
  type        = bool
  default     = true
}

variable "aks_enable_logging" {
  description = "Enable logging to Azure Log Analytics"
  type        = bool
  default     = true
}

# Application Gateway Variables
variable "appgw_subnet_address_prefix" {
  description = "Address prefix for the Application Gateway subnet"
  type        = string
  default     = "10.0.3.0/24" # Make sure this doesn't overlap with existing subnets
}

variable "enable_app_gateway" {
  description = "Enable Application Gateway as ingress to AKS"
  type        = bool
  default     = true
}
