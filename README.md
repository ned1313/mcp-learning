# Azure Network Infrastructure with Terraform

This repository contains Terraform code to deploy a basic Azure network infrastructure, including:

- Resource Group
- Virtual Network
- Two Subnets
- Network Security Group
- Azure Kubernetes Service (AKS) Cluster with autoscaling
- Azure Application Gateway with AKS Ingress Controller (AGIC)

## Prerequisites

- [Terraform](https://developer.hashicorp.com/terraform/downloads) (>= 1.0.0)
- Azure CLI installed and configured
- Azure Subscription

## Installation

If you don't have Terraform installed, you can install it using Winget:

```powershell
winget install Hashicorp.Terraform
```

## Configuration

Edit the `terraform.tfvars` file to customize the deployment:

- `prefix`: Prefix for resource naming
- `location`: Azure region for deployment
- `environment`: Environment tag (dev, test, prod)
- `vnet_address_space`: CIDR block for the virtual network
- `subnet1_address_prefix`: CIDR block for the first subnet
- `subnet2_address_prefix`: CIDR block for the second subnet
- `admin_cidr_block`: CIDR block for administrative access (update for security)

### AKS Configuration

- `aks_node_size`: VM size for AKS nodes (default: Standard_D2s_v3)
- `aks_node_count`: Initial number of nodes (default: 3)
- `aks_min_node_count`: Minimum number of nodes for autoscaling (default: 3)
- `aks_max_node_count`: Maximum number of nodes for autoscaling (default: 5)
- `aks_enable_auto_scaling`: Enable/disable autoscaling (default: true)
- `aks_enable_logging`: Enable/disable Log Analytics integration (default: true)

### Application Gateway Configuration

- `appgw_subnet_address_prefix`: CIDR block for the Application Gateway subnet (default: 10.0.3.0/24)
- `enable_app_gateway`: Enable/disable Application Gateway as ingress (default: true)

## Deployment Instructions

1. Initialize Terraform:

```powershell
terraform init
```

2. Validate the configuration:

```powershell
terraform validate
```

3. Preview the changes:

```powershell
terraform plan
```

4. Apply the configuration:

```powershell
terraform apply
```

Or to skip the approval prompt:

```powershell
terraform apply -auto-approve
```

## Outputs

After successful deployment, you'll get the following outputs:

- Resource Group ID and Name
- Virtual Network ID and Name
- Subnet IDs
- CIDR ranges of the subnets
- AKS Cluster ID, Name, and FQDN
- AKS Kubernetes configuration for kubectl
- Azure Portal URL to view the resources

## Accessing the AKS Cluster

After deployment, you can access your AKS cluster using kubectl:

```powershell
# Get credentials for your AKS cluster
az aks get-credentials --resource-group <resource-group-name> --name <aks-cluster-name>

# Verify connection to cluster
kubectl get nodes
```

## Using Application Gateway Ingress Controller (AGIC)

After deployment, you can expose your Kubernetes services through the Application Gateway by creating Ingress resources:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    kubernetes.io/ingress.class: azure/application-gateway
spec:
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: your-service-name
            port:
              number: 80
```

Deploy the Ingress resource:

```powershell
kubectl apply -f your-ingress.yaml
```

Access your service through the Application Gateway's public IP address:

```powershell
# Get Application Gateway Public IP
terraform output app_gateway_public_ip
```

## Security Considerations

- Update the `admin_cidr_block` in `terraform.tfvars` to restrict access to your specific IP range
- For production environments, consider using the backend configuration for remote state storage
- Review the NSG rules and adjust according to your security requirements
- Consider enabling private AKS cluster for production workloads

## Clean Up

To remove all resources:

```powershell
terraform destroy
```

## Pre-commit Hooks

This repository uses pre-commit hooks to ensure code quality and consistent documentation. The hooks run the following tools:

- **terraform fmt** - Formats Terraform code
- **terraform validate** - Validates Terraform code
- **tfsec** - Performs static analysis against Terraform code
- **terraform-docs** - Updates README.md with Terraform module documentation
- **check-sensitive-info** - Scans for sensitive information like keys and passwords
- **check-tf-best-practices** - Verifies Terraform code follows best practices

### Setup

Run the setup script to install pre-commit and the required tools:

```powershell
.\setup-hooks.ps1
```

### Manual Execution

You can manually run the pre-commit hooks on all files:

```powershell
pre-commit run --all-files
```

Or run the manual script:

```powershell
.\manual-pre-commit.ps1
```

### Comprehensive Checking Tool

For a more comprehensive checking experience with detailed reporting, run:

```powershell
.\run-all-checks.ps1
```

You can skip specific checks using parameters:

```powershell
.\run-all-checks.ps1 -SkipSecurity -SkipBestPractices
```

Available parameters:
- `-SkipFormat`: Skip code formatting
- `-SkipSensitiveCheck`: Skip sensitive information checks
- `-SkipSecurity`: Skip security scanning
- `-SkipBestPractices`: Skip best practices check
- `-SkipDocs`: Skip documentation generation

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.0 |
| <a name="requirement_tls"></a> [tls](#requirement\_tls) | >= 3.1 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.117.1 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aks"></a> [aks](#module\_aks) | Azure/aks/azurerm | 7.5.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_network_security_group.subnet1_nsg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/network_security_group) | resource |
| [azurerm_public_ip.appgw_pip](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_resource_group.rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_subnet.appgw_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.subnet1](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet.subnet2](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_network_security_group_association.subnet1_nsg_association](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_network_security_group_association) | resource |
| [azurerm_virtual_network.vnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_admin_cidr_block"></a> [admin\_cidr\_block](#input\_admin\_cidr\_block) | CIDR block for admin access | `string` | `"0.0.0.0/0"` | no |
| <a name="input_aks_enable_auto_scaling"></a> [aks\_enable\_auto\_scaling](#input\_aks\_enable\_auto\_scaling) | Enable node pool autoscaling | `bool` | `true` | no |
| <a name="input_aks_enable_logging"></a> [aks\_enable\_logging](#input\_aks\_enable\_logging) | Enable logging to Azure Log Analytics | `bool` | `true` | no |
| <a name="input_aks_max_node_count"></a> [aks\_max\_node\_count](#input\_aks\_max\_node\_count) | Maximum number of nodes for the AKS cluster autoscaling | `number` | `5` | no |
| <a name="input_aks_min_node_count"></a> [aks\_min\_node\_count](#input\_aks\_min\_node\_count) | Minimum number of nodes for the AKS cluster autoscaling | `number` | `3` | no |
| <a name="input_aks_node_count"></a> [aks\_node\_count](#input\_aks\_node\_count) | Initial number of nodes in AKS cluster | `number` | `3` | no |
| <a name="input_aks_node_size"></a> [aks\_node\_size](#input\_aks\_node\_size) | Size of the AKS worker nodes | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_appgw_subnet_address_prefix"></a> [appgw\_subnet\_address\_prefix](#input\_appgw\_subnet\_address\_prefix) | Address prefix for the Application Gateway subnet | `string` | `"10.0.3.0/24"` | no |
| <a name="input_enable_app_gateway"></a> [enable\_app\_gateway](#input\_enable\_app\_gateway) | Enable Application Gateway as ingress to AKS | `bool` | `true` | no |
| <a name="input_enable_service_endpoints"></a> [enable\_service\_endpoints](#input\_enable\_service\_endpoints) | Enable service endpoints on subnets | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment tag (e.g., dev, test, prod) | `string` | `"dev"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version to use for the AKS cluster | `string` | `null` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region where resources will be deployed | `string` | `"East US"` | no |
| <a name="input_owner"></a> [owner](#input\_owner) | Owner tag for resources | `string` | `"terraform"` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix for naming resources | `string` | `"terraproj"` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name tag for resources | `string` | `"terraform-network-demo"` | no |
| <a name="input_subnet1_address_prefix"></a> [subnet1\_address\_prefix](#input\_subnet1\_address\_prefix) | Address prefix for the first subnet | `string` | `"10.0.1.0/24"` | no |
| <a name="input_subnet2_address_prefix"></a> [subnet2\_address\_prefix](#input\_subnet2\_address\_prefix) | Address prefix for the second subnet | `string` | `"10.0.2.0/24"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | A map of tags to apply to all resources | `map(string)` | <pre>{<br/>  "Environment": "dev",<br/>  "ManagedBy": "terraform",<br/>  "Owner": "terraform",<br/>  "Project": "terraform-network-demo"<br/>}</pre> | no |
| <a name="input_vnet_address_space"></a> [vnet\_address\_space](#input\_vnet\_address\_space) | Address space for the virtual network | `string` | `"10.0.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks_fqdn"></a> [aks\_fqdn](#output\_aks\_fqdn) | FQDN of the AKS cluster |
| <a name="output_aks_id"></a> [aks\_id](#output\_aks\_id) | ID of the AKS cluster |
| <a name="output_aks_kube_config_raw"></a> [aks\_kube\_config\_raw](#output\_aks\_kube\_config\_raw) | Raw kubectl configuration for the AKS cluster |
| <a name="output_aks_name"></a> [aks\_name](#output\_aks\_name) | Name of the AKS cluster |
| <a name="output_aks_node_resource_group"></a> [aks\_node\_resource\_group](#output\_aks\_node\_resource\_group) | Auto-generated resource group for AKS nodes |
| <a name="output_app_gateway_name"></a> [app\_gateway\_name](#output\_app\_gateway\_name) | Name of the Application Gateway |
| <a name="output_app_gateway_public_ip"></a> [app\_gateway\_public\_ip](#output\_app\_gateway\_public\_ip) | Public IP address of the Application Gateway |
| <a name="output_app_gateway_url"></a> [app\_gateway\_url](#output\_app\_gateway\_url) | URL of the Application Gateway |
| <a name="output_azure_portal_url"></a> [azure\_portal\_url](#output\_azure\_portal\_url) | URL to view resources in Azure Portal |
| <a name="output_resource_group_id"></a> [resource\_group\_id](#output\_resource\_group\_id) | ID of the created resource group |
| <a name="output_resource_group_name"></a> [resource\_group\_name](#output\_resource\_group\_name) | Name of the created resource group |
| <a name="output_subnet1_cidr"></a> [subnet1\_cidr](#output\_subnet1\_cidr) | Address range of the first subnet |
| <a name="output_subnet1_id"></a> [subnet1\_id](#output\_subnet1\_id) | ID of the first subnet |
| <a name="output_subnet2_cidr"></a> [subnet2\_cidr](#output\_subnet2\_cidr) | Address range of the second subnet |
| <a name="output_subnet2_id"></a> [subnet2\_id](#output\_subnet2\_id) | ID of the second subnet |
| <a name="output_virtual_network_id"></a> [virtual\_network\_id](#output\_virtual\_network\_id) | ID of the created virtual network |
| <a name="output_virtual_network_name"></a> [virtual\_network\_name](#output\_virtual\_network\_name) | Name of the created virtual network |
<!-- END_TF_DOCS -->
