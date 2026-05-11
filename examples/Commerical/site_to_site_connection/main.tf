# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "mod_vng" {
  #source  = "github.com/POps-Rox/terraform-az-overlays-vnetgateway"
  #version = "x.x.x"
  source = "../../.."

  depends_on = [azurerm_resource_group.vng-network-rg]

  # Resource Group, location, details
  existing_resource_group_name = azurerm_resource_group.vng-network-rg.name
  location                     = var.location
  deploy_environment           = var.deploy_environment
  environment                  = var.environment
  org_name                     = var.org_name
  workload_name                = var.workload_name

  # VNet Gateway details
  sku                           = "VpnGw1"
  gateway_subnet_address_prefix = "10.0.2.0/24"
  type                          = "Vpn"
  enable_vpn_bgp                = true

  # BGP settings
  vpn_bgp_settings = {
    asn = 65515
  }

  # Local Network Gateway
  local_network_gateways = {
    "onpremise" = {
      tags = {
        environment = "test"
      }
      gateway_address = "168.62.225.23"
      address_space   = ["10.1.1.0/24"]
    }
  }

  # Virtual Network Configuration
  existing_virtual_network_resource_group_name = azurerm_resource_group.vng-network-rg.name
  existing_virtual_network_name                = azurerm_virtual_network.vng-vnet.name
}
