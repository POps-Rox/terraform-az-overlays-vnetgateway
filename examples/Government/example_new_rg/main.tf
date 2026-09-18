# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "mod_example" {
  #source  = "github.com/POps-Rox/tf-overlays-template"
  #version = "x.x.x"
  source = "../../.."

  # Resource Group, location, VNet and Subnet details
  create_resource_group = true
  location              = var.location
  deploy_environment    = var.deploy_environment
  environment           = var.environment
  org_name              = var.org_name
  workload_name         = var.workload_name

  # VNet Gateway details
  sku                           = "VpnGw1"
  type                          = "Vpn"
  gateway_subnet_address_prefix = "10.0.2.0/24"

  # Virtual Network Configuration
  existing_virtual_network_resource_group_name = azurerm_resource_group.example-network-rg.name
  existing_virtual_network_name                = azurerm_virtual_network.example-vnet.name

  #echo_text = "Hello, world!"
}
