<!-- BADGES:START -->
[![CI](https://github.com/POps-Rox/tf-az-overlays-vnetgateway/actions/workflows/ci.yml/badge.svg)](https://github.com/POps-Rox/tf-az-overlays-vnetgateway/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/POps-Rox/tf-az-overlays-vnetgateway/pulls)
[![Maintained](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/POps-Rox/tf-az-overlays-vnetgateway/graphs/commit-activity)
[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.5-623CE4.svg?logo=terraform)](https://www.terraform.io)
<!-- BADGES:END -->

# Azure VNet Gateway Overlay Terraform Module

[![Changelog](https://img.shields.io/badge/changelog-release-green.svg)](CHANGELOG.md) [![Notice](https://img.shields.io/badge/notice-copyright-yellow.svg)](NOTICE) [![MIT License](https://img.shields.io/badge/license-MIT-orange.svg)](LICENSE) [![TF Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/POps-Rox/overlays-vnet-gateway/azurerm/)

This Overlay terraform module can deploy and manage a Azure VNet Gateway and its associated resources. This module can be used in a [SCCA compliant Network](https://registry.terraform.io/modules/POps-Rox/overlays-hubspoke/azurerm/latest).

## Using Azure Clouds

Since this module is built for both public and us government clouds. The `environment` variable defaults to `public` for Azure Cloud. When using this module with the Azure Government Cloud, you must set the `environment` variable to `usgovernment`. You will also need to set the azurerm provider `environment` variable to the proper cloud as well. This will ensure that the correct Azure Government Cloud endpoints are used. You will also need to set the `location` variable to a valid Azure Government Cloud location.

Example Usage for Azure Government Cloud:

```hcl

provider "azurerm" {
  environment = "usgovernment"
}

module "mod_ampls" {
  source  = "POps-Rox/tf-az-overlays-vnet-gateway/azurerm"
  version = "x.x.x"
  
  location = "usgovvirginia"
  environment = "usgovernment"
  ...
}

```

## SCCA Compliance

This module can be SCCA compliant and can be used in a SCCA compliant Network. Enable private endpoints and SCCA compliant network rules to make it SCCA compliant.

For more information, please read the [SCCA documentation](https://github.com/POps-Rox/tf-az-overlays-compute-image-gallery/blob/main).

## Contributing

If you want to contribute to this repository, feel free to to contribute to our Terraform module.

More details are available in the [CONTRIBUTING.md](./CONTRIBUTING.md#pull-request-process) file.

## License

This Terraform module is open-sourced software licensed under the [MIT License](https://opensource.org/licenses/MIT).

## Resources Supported

| Name | Type |
|------|------|
| [azurerm_express_route_circuit_peering.vgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit_peering) | resource |
| [azurerm_local_network_gateway.vgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway) | resource |
| [azurerm_public_ip.vgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_route_table.vgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_subnet.vgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_route_table_association.vgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network_gateway.vgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway) | resource |
| [azurerm_virtual_network_gateway_connection.vgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection) | resource |
| [popsrox_resource_name.express_route_circuit](https://registry.terraform.io/providers/POps-Rox/popsrox-utils/latest/docs/data-sources/resource_name) | data source |
| [popsrox_resource_name.local_network_gateway](https://registry.terraform.io/providers/POps-Rox/popsrox-utils/latest/docs/data-sources/resource_name) | data source |
| [popsrox_resource_name.virtual_network_gateway](https://registry.terraform.io/providers/POps-Rox/popsrox-utils/latest/docs/data-sources/resource_name) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.rgrp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Module Usage

```hcl
# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

module "mod_vng" {
  source  = "POps-Rox/tf-az-overlays-vnet-gateway/azurerm"
  version = "x.x.x"

  depends_on = [azurerm_virtual_network.example-vnet, azurerm_subnet.example-snet, azurerm_log_analytics_workspace.example-log]

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
  
  # Tags
  add_tags = {} # Tags to be applied to all resources
}

```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9 |
| <a name="requirement_popsrox-utils"></a> [popsrox-utils](#requirement_popsrox-utils) | ~> 1.0.4 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 3.116 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_popsrox-utils"></a> [popsrox-utils](#provider_popsrox-utils) | ~> 1.0.4 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | ~> 3.116 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_mod_azure_region_lookup"></a> [mod\_azure\_region\_lookup](#module\_mod\_azure\_region\_lookup) | POps-Rox/overlays-azregions-lookup/azurerm | ~> 1.0.0 |
| <a name="module_mod_scaffold_rg"></a> [mod\_scaffold\_rg](#module\_mod\_scaffold\_rg) | POps-Rox/overlays-resource-group/azurerm | ~> 1.0.1 |

## Resources

| Name | Type |
|------|------|
| [azurerm_express_route_circuit_peering.vgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/express_route_circuit_peering) | resource |
| [azurerm_local_network_gateway.vgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/local_network_gateway) | resource |
| [azurerm_public_ip.vgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/public_ip) | resource |
| [azurerm_route_table.vgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/route_table) | resource |
| [azurerm_subnet.vgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet) | resource |
| [azurerm_subnet_route_table_association.vgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet_route_table_association) | resource |
| [azurerm_virtual_network_gateway.vgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway) | resource |
| [azurerm_virtual_network_gateway_connection.vgw](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network_gateway_connection) | resource |
| [popsrox_resource_name.express_route_circuit](https://registry.terraform.io/providers/POps-Rox/popsrox-utils/latest/docs/data-sources/resource_name) | data source |
| [popsrox_resource_name.local_network_gateway](https://registry.terraform.io/providers/POps-Rox/popsrox-utils/latest/docs/data-sources/resource_name) | data source |
| [popsrox_resource_name.virtual_network_gateway](https://registry.terraform.io/providers/POps-Rox/popsrox-utils/latest/docs/data-sources/resource_name) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_resource_group.rgrp](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/resource_group) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_add_tags"></a> [add\_tags](#input\_add\_tags) | Map of custom tags. | `map(string)` | `{}` | no |
| <a name="input_create_private_endpoint_subnet"></a> [create\_private\_endpoint\_subnet](#input\_create\_private\_endpoint\_subnet) | Controls if the subnet should be created. If set to false, the subnet name must be provided. Default is false. | `bool` | `false` | no |
| <a name="input_create_resource_group"></a> [create\_resource\_group](#input\_create\_resource\_group) | Controls if the resource group should be created. If set to false, the resource group name must be provided. Default is false. | `bool` | `false` | no |
| <a name="input_custom_express_route_circuit_name"></a> [custom\_express\_route\_circuit\_name](#input\_custom\_express\_route\_circuit\_name) | The name of the custom express route circuit to create. If not set, the name will be generated using the `org_name`, `workload_name`, `deploy_environment` and `environment` variables. | `string` | `null` | no |
| <a name="input_custom_local_network_gateway_name"></a> [custom\_local\_network\_gateway\_name](#input\_custom\_local\_network\_gateway\_name) | The name of the custom local network gateway to create. If not set, the name will be generated using the `org_name`, `workload_name`, `deploy_environment` and `environment` variables. | `string` | `null` | no |
| <a name="input_custom_resource_group_name"></a> [custom\_resource\_group\_name](#input\_custom\_resource\_group\_name) | The name of the custom resource group to create. If not set, the name will be generated using the `org_name`, `workload_name`, `deploy_environment` and `environment` variables. | `string` | `null` | no |
| <a name="input_custom_virtual_network_gateway_name"></a> [custom\_virtual\_network\_gateway\_name](#input\_custom\_virtual\_network\_gateway\_name) | The name of the custom virtual network gateway to create. If not set, the name will be generated using the `org_name`, `workload_name`, `deploy_environment` and `environment` variables. | `string` | `null` | no |
| <a name="input_default_tags_enabled"></a> [default\_tags\_enabled](#input\_default\_tags\_enabled) | Option to enable or disable default tags. | `bool` | `true` | no |
| <a name="input_deploy_environment"></a> [deploy\_environment](#input\_deploy\_environment) | Name of the workload's environment | `string` | n/a | yes |
| <a name="input_edge_zone"></a> [edge\_zone](#input\_edge\_zone) | The availability zone of the Virtual Network Gateway. Only supported for AZ SKUs. | `string` | `null` | no |
| <a name="input_enable_private_endpoint"></a> [enable\_private\_endpoint](#input\_enable\_private\_endpoint) | Manages a Private Endpoint to Azure Container Registry. Default is false. | `bool` | `false` | no |
| <a name="input_enable_resource_locks"></a> [enable\_resource\_locks](#input\_enable\_resource\_locks) | (Optional) Enable resource locks, default is false. If true, resource locks will be created for the resource group and the storage account. | `bool` | `false` | no |
| <a name="input_enable_route_table_bgp_route_propagation"></a> [enable\_route\_table\_bgp\_route\_propagation](#input\_enable\_route\_table\_bgp\_route\_propagation) | Whether or not to enable BGP route propagation on the Route Table. | `bool` | `true` | no |
| <a name="input_enable_route_table_creation"></a> [enable\_route\_table\_creation](#input\_enable\_route\_table\_creation) | Whether or not to create a Route Table associated with the Virtual Network Gateway Subnet. | `bool` | `false` | no |
| <a name="input_enable_vpn_active_active"></a> [enable\_vpn\_active\_active](#input\_enable\_vpn\_active\_active) | Enable active-active mode for the Virtual Network Gateway. | `bool` | `false` | no |
| <a name="input_enable_vpn_bgp"></a> [enable\_vpn\_bgp](#input\_enable\_vpn\_bgp) | Enable BGP for the Virtual Network Gateway. | `bool` | `false` | no |
| <a name="input_enable_vpn_private_ip_address"></a> [enable\_vpn\_private\_ip\_address](#input\_enable\_vpn\_private\_ip\_address) | Enable private IP address for the Virtual Network Gateway for Virtual Network Gateway Connections. Only supported for AZ SKUs. | `bool` | `null` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The Terraform backend environment e.g. public or usgovernment | `string` | n/a | yes |
| <a name="input_existing_gateway_subnet_id"></a> [existing\_gateway\_subnet\_id](#input\_existing\_gateway\_subnet\_id) | The ID of a pre-existing gateway subnet to use for the Virtual Network Gateway. Either subnet\_id or subnet\_address\_prefix must be specified. | `string` | `""` | no |
| <a name="input_existing_private_dns_zone"></a> [existing\_private\_dns\_zone](#input\_existing\_private\_dns\_zone) | Name of the existing private DNS zone | `any` | `null` | no |
| <a name="input_existing_private_subnet_name"></a> [existing\_private\_subnet\_name](#input\_existing\_private\_subnet\_name) | Name of the existing subnet for the private endpoint | `any` | `null` | no |
| <a name="input_existing_resource_group_name"></a> [existing\_resource\_group\_name](#input\_existing\_resource\_group\_name) | The name of the existing resource group to use. If not set, the name will be generated using the `org_name`, `workload_name`, `deploy_environment` and `environment` variables. | `string` | `null` | no |
| <a name="input_existing_virtual_network_name"></a> [existing\_virtual\_network\_name](#input\_existing\_virtual\_network\_name) | The name of the Existing Virtual Network. | `string` | n/a | yes |
| <a name="input_existing_virtual_network_resource_group_name"></a> [existing\_virtual\_network\_resource\_group\_name](#input\_existing\_virtual\_network\_resource\_group\_name) | The name of the Existing Virtual Network's Resource Group. If not specified, the module created resourxe group will be used. | `string` | `null` | no |
| <a name="input_express_route_circuits"></a> [express\_route\_circuits](#input\_express\_route\_circuits) | Map of Virtual Network Gateway Connections and Peering Configurations to create for existing ExpressRoute circuits.<br><br>- `id` - (Required) The ID of the ExpressRoute circuit.<br><br>- `connection` - (Optional) a `connection` block as defined below. Used to configure the Virtual Network Gateway Connection between the ExpressRoute Circuit and the Virtual Network Gateway.<br>  - `authorization_key` - (Optional) The authorization key for the ExpressRoute Circuit.<br>  - `express_route_gateway_bypass` - (Optional) Whether to bypass the ExpressRoute Gateway for data forwarding.<br>  - `name` - (Optional) The name of the Virtual Network Gateway Connection.<br>  - `routing_weight` - (Optional) The weight added to routes learned from this Virtual Network Gateway Connection. Defaults to 10.<br>  - `shared_key` - (Optional) The shared key for the Virtual Network Gateway Connection.<br>  - `tags` - (Optional) A mapping of tags to assign to the resource.<br><br>- `peering` - (Optional) a `peering` block as defined below. Used to configure the ExpressRoute Circuit Peering.<br>  - `peering_type` - (Required) The type of the peering. Possible values are AzurePrivatePeering, AzurePublicPeering or MicrosoftPeering.<br>  - `vlan_id` - (Required) The VLAN ID for the peering.<br>  - `ipv4_enabled` - (Optional) Whether IPv4 is enabled on the peering. Defaults to true.<br>  - `peer_asn` - (Optional) The peer ASN.<br>  - `primary_peer_address_prefix` - (Optional) The primary address prefix.<br>  - `secondary_peer_address_prefix` - (Optional) The secondary address prefix.<br>  - `shared_key` - (Optional) The shared key for the peering.<br>  - `route_filter_id` - (Optional) The ID of the route filter to apply to the peering.<br>  - `microsoft_peering_config` - (Optional) a `microsoft_peering_config` block as defined below. Used to configure the Microsoft Peering.<br>    - `advertised_communities` - (Optional) The list of communities to advertise to the Microsoft Peering.<br>    - `advertised_public_prefixes` - (Required) The list of public prefixes to advertise to the Microsoft Peering.<br>    - `customer_asn` - (Optional) The customer ASN.<br>    - `routing_registry_name` - (Optional) The routing registry name. | <pre>map(object({<br>    id                  = string<br>    resource_group_name = optional(string, null)<br>    connection = optional(object({<br>      authorization_key            = optional(string, null)<br>      express_route_gateway_bypass = optional(bool, null)<br>      name                         = optional(string, null)<br>      routing_weight               = optional(number, null)<br>      shared_key                   = optional(string, null)<br>      tags                         = optional(map(string), {})<br>    }), null)<br>    peering = optional(object({<br>      peering_type                  = string<br>      vlan_id                       = number<br>      ipv4_enabled                  = optional(bool, true)<br>      peer_asn                      = optional(number, null)<br>      primary_peer_address_prefix   = optional(string, null)<br>      secondary_peer_address_prefix = optional(string, null)<br>      shared_key                    = optional(string, null)<br>      route_filter_id               = optional(string, null)<br>      microsoft_peering_config = optional(object({<br>        advertised_public_prefixes = list(string)<br>        advertised_communities     = optional(list(string), null)<br>        customer_asn               = optional(number, null)<br>        routing_registry_name      = optional(string, null)<br>      }), null)<br>    }), null)<br>  }))</pre> | `{}` | no |
| <a name="input_gateway_subnet_address_prefix"></a> [gateway\_subnet\_address\_prefix](#input\_gateway\_subnet\_address\_prefix) | The address prefix for the gateway subnet. Either subnet\_id or subnet\_address\_prefix must be specified. | `string` | `""` | no |
| <a name="input_ip_configurations"></a> [ip\_configurations](#input\_ip\_configurations) | Map of IP Configurations to create for the Virtual Network Gateway.<br><br>- `ip_configuration_name` - (Optional) The name of the IP Configuration.<br>- `apipa_addresses` - (Optional) The list of APPIPA addresses.<br>- `private_ip_address_allocation` - (Optional) The private IP allocation method. Possible values are Static or Dynamic. Defaults to Dynamic.<br>- `public_ip` - (Optional) a `public_ip` block as defined below. Used to configure the Public IP Address for the IP Configuration.<br>  - `name` - (Optional) The name of the Public IP Address.<br>  - `allocation_method` - (Optional) The allocation method of the Public IP Address. Possible values are Static or Dynamic. Defaults to Dynamic.<br>  - `sku` - (Optional) The SKU of the Public IP Address. Possible values are Basic or Standard. Defaults to Basic.<br>  - `tags` - (Optional) A mapping of tags to assign to the resource. | <pre>map(object({<br>    ip_configuration_name         = optional(string, null)<br>    apipa_addresses               = optional(list(string), null)<br>    private_ip_address_allocation = optional(string, "Dynamic")<br>    public_ip = optional(object({<br>      name              = optional(string, null)<br>      allocation_method = optional(string, "Dynamic")<br>      sku               = optional(string, "Basic")<br>      tags              = optional(map(string), {})<br>    }), {})<br>  }))</pre> | `{}` | no |
| <a name="input_local_network_gateways"></a> [local\_network\_gateways](#input\_local\_network\_gateways) | Map of Local Network Gateways and Virtual Network Gateway Connections to create for the Virtual Network Gateway.<br><br>- `id` - (Optional) The ID of the pre-exisitng Local Network Gateway.<br>- `name` - (Optional) The name of the Local Network Gateway to create.<br>- `address_space` - (Optional) The list of address spaces for the Local Network Gateway.<br>- `gateway_fqdn` - (Optional) The gateway FQDN for the Local Network Gateway.<br>- `gateway_address` - (Optional) The gateway IP address for the Local Network Gateway.<br>- `tags` - (Optional) A mapping of tags to assign to the resource.<br>- `bgp_settings` - (Optional) a `bgp_settings` block as defined below. Used to configure the BGP settings for the Local Network Gateway.<br>  - `asn` - (Required) The ASN of the Local Network Gateway.<br>  - `bgp_peering_address` - (Required) The BGP peering address of the Local Network Gateway.<br>  - `peer_weight` - (Optional) The weight added to routes learned from this BGP speaker.<br><br>- `connection` - (Optional) a `connection` block as defined below. Used to configure the Virtual Network Gateway Connection for the Local Network Gateway.<br>  - `name` - (Optional) The name of the Virtual Network Gateway Connection.<br>  - `type` - (Required) The type of Virtual Network Gateway Connection. Possible values are IPsec or Vnet2Vnet.<br>  - `connection_mode` - (Optional) The connection mode.<br>  - `connection_protocol` - (Optional) The connection protocol. Possible values are IKEv2 or IKEv1.<br>  - `dpd_timeout_seconds` - (Optional) The dead peer detection timeout in seconds.<br>  - `egress_nat_rule_ids` - (Optional) The list of egress NAT rule IDs.<br>  - `enable_bgp` - (Optional) Whether or not BGP is enabled for this Virtual Network Gateway Connection.<br>  - `ingress_nat_rule_ids` - (Optional) The list of ingress NAT rule IDs.<br>  - `local_azure_ip_address_enabled` - (Optional) Whether or not the local Azure IP address is enabled.<br>  - `peer_virtual_network_gateway_id` - (Optional) The ID of the peer Virtual Network Gateway.<br>  - `routing_weight` - (Optional) The routing weight.<br>  - `shared_key` - (Optional) The shared key.<br>  - `tags` - (Optional) A mapping of tags to assign to the resource.<br>  - `use_policy_based_traffic_selectors` - (Optional) Whether or not to use policy based traffic selectors.<br>  - `custom_bgp_addresses` - (Optional) a `custom_bgp_addresses` block as defined below. Used to configure the custom BGP addresses for the Virtual Network Gateway Connection.<br>    - `primary` - (Required) The primary custom BGP address.<br>    - `secondary` - (Required) The secondary custom BGP address.<br>  - `ipsec_policy` - (Optional) a `ipsec_policy` block as defined below. Used to configure the IPsec policy for the Virtual Network Gateway Connection.<br>    - `dh_group` - (Required) The DH Group used in IKE Phase 1 for initial SA.<br>    - `ike_encryption` - (Required) The IKE encryption algorithm (IKE phase 2).<br>    - `ike_integrity` - (Required) The IKE integrity algorithm (IKE phase 2).<br>    - `ipsec_encryption` - (Required) The IPSec encryption algorithm (IKE phase 1).<br>    - `ipsec_integrity` - (Required) The IPSec integrity algorithm (IKE phase 1).<br>    - `pfs_group` - (Required) The Pfs Group used in IKE Phase 2 for new child SA.<br>    - `sa_datasize` - (Optional) The IPSec Security Association (also called Quick Mode or Phase 2 SA) data size specified in KB for a policy.<br>    - `sa_lifetime` - (Optional) The IPSec Security Association (also called Quick Mode or Phase 2 SA) lifetime specified in seconds for a policy.<br>  - `traffic_selector_policy` - (Optional) a `traffic_selector_policy` block as defined below. Used to configure the traffic selector policy for the Virtual Network Gateway Connection.<br>    - `local_address_prefixes` - (Required) The list of local address prefixes.<br>    - `remote_address_prefixes` - (Required) The list of remote address prefixes. | <pre>map(object({<br>    id              = optional(string, null)<br>    name            = optional(string, null)<br>    address_space   = optional(list(string), null)<br>    gateway_fqdn    = optional(string, null)<br>    gateway_address = optional(string, null)<br>    tags            = optional(map(string), {})<br>    bgp_settings = optional(object({<br>      asn                 = number<br>      bgp_peering_address = string<br>      peer_weight         = optional(number, null)<br>    }), null)<br>    connection = optional(object({<br>      name                               = optional(string, null)<br>      type                               = string<br>      connection_mode                    = optional(string, null)<br>      connection_protocol                = optional(string, null)<br>      dpd_timeout_seconds                = optional(number, null)<br>      egress_nat_rule_ids                = optional(list(string), null)<br>      enable_bgp                         = optional(bool, null)<br>      ingress_nat_rule_ids               = optional(list(string), null)<br>      local_azure_ip_address_enabled     = optional(bool, null)<br>      peer_virtual_network_gateway_id    = optional(string, null)<br>      routing_weight                     = optional(number, null)<br>      shared_key                         = optional(string, null)<br>      tags                               = optional(map(string), null)<br>      use_policy_based_traffic_selectors = optional(bool, null)<br>      custom_bgp_addresses = optional(object({<br>        primary   = string<br>        secondary = string<br>      }), null)<br>      ipsec_policy = optional(object({<br>        dh_group         = string<br>        ike_encryption   = string<br>        ike_integrity    = string<br>        ipsec_encryption = string<br>        ipsec_integrity  = string<br>        pfs_group        = string<br>        sa_datasize      = optional(number, null)<br>        sa_lifetime      = optional(number, null)<br>      }), null)<br>      traffic_selector_policy = optional(list(<br>        object({<br>          local_address_prefixes  = list(string)<br>          remote_address_prefixes = list(string)<br>        })<br>      ), null)<br>    }), null)<br>  }))</pre> | `{}` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region in which instance will be hosted | `string` | n/a | yes |
| <a name="input_lock_level"></a> [lock\_level](#input\_lock\_level) | (Optional) id locks are enabled, Specifies the Level to be used for this Lock. | `string` | `"CanNotDelete"` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Optional prefix for the generated name | `string` | `""` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Optional suffix for the generated name | `string` | `""` | no |
| <a name="input_org_name"></a> [org\_name](#input\_org\_name) | Name of the organization | `string` | n/a | yes |
| <a name="input_private_subnet_address_prefix"></a> [private\_subnet\_address\_prefix](#input\_private\_subnet\_address\_prefix) | The name of the subnet for private endpoints | `any` | `null` | no |
| <a name="input_route_table_name"></a> [route\_table\_name](#input\_route\_table\_name) | Name of the Route Table associated with Virtual Network Gateway Subnet. | `string` | `null` | no |
| <a name="input_route_table_tags"></a> [route\_table\_tags](#input\_route\_table\_tags) | Tags for the Route Table. | `map(string)` | `{}` | no |
| <a name="input_sku"></a> [sku](#input\_sku) | The SKU (size) of the Virtual Network Gateway. | `string` | n/a | yes |
| <a name="input_type"></a> [type](#input\_type) | The type of the Virtual Network Gateway, ExpressRoute or VPN. | `string` | n/a | yes |
| <a name="input_use_location_short_name"></a> [use\_location\_short\_name](#input\_use\_location\_short\_name) | Use short location name for resources naming (ie eastus -> eus). Default is true. If set to false, the full cli location name will be used. if custom naming is set, this variable will be ignored. | `bool` | `true` | no |
| <a name="input_use_naming"></a> [use\_naming](#input\_use\_naming) | Use the Azure NoOps naming provider to generate default resource name. `storage_account_custom_name` override this if set. Legacy default name is used if this is set to `false`. | `bool` | `true` | no |
| <a name="input_virtual_network_name"></a> [virtual\_network\_name](#input\_virtual\_network\_name) | Name of the virtual network for the private endpoint | `any` | `null` | no |
| <a name="input_vpn_bgp_settings"></a> [vpn\_bgp\_settings](#input\_vpn\_bgp\_settings) | BGP settings for the Virtual Network Gateway. | <pre>object({<br>    asn         = optional(number, null)<br>    peer_weight = optional(number, null)<br>  })</pre> | `null` | no |
| <a name="input_vpn_generation"></a> [vpn\_generation](#input\_vpn\_generation) | value for the Generation for the Gateway, Valid values are 'Generation1', 'Generation2'. Options differ depending on SKU. | `string` | `null` | no |
| <a name="input_vpn_point_to_site"></a> [vpn\_point\_to\_site](#input\_vpn\_point\_to\_site) | Point to site configuration for the virtual network gateway.<br><br>- `address_space` - (Required) Address space for the virtual network gateway.<br>- `aad_tenant` - (Optional) The AAD tenant to use for authentication.<br>- `aad_audience` - (Optional) The AAD audience to use for authentication.<br>- `aad_issuer` - (Optional) The AAD issuer to use for authentication.<br>- `radius_server_address` - (Optional) The address of the radius server.<br>- `radius_server_secret` - (Optional) The secret of the radius server.<br>- `root_certificate` - (Optional) The root certificate of the virtual network gateway.<br>  - `name` - (Required) The name of the root certificate.<br>  - `public_cert_data` - (Required) The public certificate data.<br>- `revoked_certificate` - (Optional) The revoked certificate of the virtual network gateway.<br>  - `name` - (Required) The name of the revoked certificate.<br>  - `thumbprint` - (Required) The thumbprint of the revoked certificate.<br>- `vpn_client_protocols` - (Optional) The VPN client protocols.<br>- `vpn_auth_types` - (Optional) The VPN authentication types. | <pre>object({<br>    address_space         = list(string)<br>    aad_tenant            = optional(string, null)<br>    aad_audience          = optional(string, null)<br>    aad_issuer            = optional(string, null)<br>    radius_server_address = optional(string, null)<br>    radius_server_secret  = optional(string, null)<br>    root_certificate = optional(map(object({<br>      name             = string<br>      public_cert_data = string<br>    })), {})<br>    revoked_certificate = optional(map(object({<br>      name       = string<br>      thumbprint = string<br>    })), {})<br>    vpn_client_protocols = optional(list(string), null)<br>    vpn_auth_types       = optional(list(string), null)<br>  })</pre> | `null` | no |
| <a name="input_vpn_type"></a> [vpn\_type](#input\_vpn\_type) | The VPN type of the Virtual Network Gateway. | `string` | `"RouteBased"` | no |
| <a name="input_workload_name"></a> [workload\_name](#input\_workload\_name) | Name of the workload\_name | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_local_network_gateways"></a> [local\_network\_gateways](#output\_local\_network\_gateways) | A curated output of the Local Network Gateways created by this module. |
| <a name="output_public_ip_addresses"></a> [public\_ip\_addresses](#output\_public\_ip\_addresses) | A curated output of the Public IP Addresses created by this module. |
| <a name="output_route_table"></a> [route\_table](#output\_route\_table) | A curated output of the Route Table created by this module. |
| <a name="output_subnet"></a> [subnet](#output\_subnet) | A curated output of the GatewaySubnet created by this module. |
| <a name="output_virtual_network_gateway"></a> [virtual\_network\_gateway](#output\_virtual\_network\_gateway) | A curated output of the Virtual Network Gateway created by this module. |
| <a name="output_virtual_network_gateway_connections"></a> [virtual\_network\_gateway\_connections](#output\_virtual\_network\_gateway\_connections) | A curated output of the Virtual Network Gateway Connections created by this module. |
<!-- END_TF_DOCS -->