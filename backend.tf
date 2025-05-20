# Terraform Backend Configuration (optional)
# Uncomment and configure this file to use Azure Storage for remote state management

# terraform {
#   backend "azurerm" {
#     resource_group_name  = "terraform-state-rg"
#     storage_account_name = "tfstateaccount"
#     container_name       = "tfstate"
#     key                  = "network.terraform.tfstate"
#   }
# }
