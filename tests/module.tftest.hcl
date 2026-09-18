mock_provider "azurerm" {}
mock_provider "popsrox" {}
mock_provider "azapi" {}

override_module {
  target = module.mod_azure_region_lookup
  outputs = {
    location_cli   = "eastus2"
    location_short = "eus2"
  }
}

override_data {
  target = data.azurerm_resource_group.rgrp[0]
  values = {
    name     = "rg-existing"
    location = "eastus2"
  }
}

override_data {
  target = data.popsrox_resource_name.virtual_network_gateway
  values = {
    result = "generated-vgw"
  }
}

override_data {
  target = data.popsrox_resource_name.local_network_gateway
  values = {
    result = "generated-lgw"
  }
}

override_data {
  target = data.popsrox_resource_name.express_route_circuit
  values = {
    result = "generated-erc"
  }
}

run "default_existing_subnet_skips_optional_resources" {
  command = plan

  variables {
    location                                     = "eastus2"
    environment                                  = "public"
    deploy_environment                           = "dev"
    workload_name                                = "hub"
    org_name                                     = "contoso"
    existing_resource_group_name                 = "rg-existing"
    existing_virtual_network_name                = "vnet-hub"
    existing_virtual_network_resource_group_name = "rg-existing"
    existing_gateway_subnet_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Network/virtualNetworks/vnet-hub/subnets/GatewaySubnet"
    sku                                          = "VpnGw1"
    type                                         = "Vpn"
    add_tags = {
      owner = "network"
    }
  }

  assert {
    condition     = azurerm_virtual_network_gateway.vgw.name == "generated-vgw"
    error_message = "generated virtual network gateway name should be used when no custom name is supplied"
  }

  assert {
    condition     = local.virtual_network_gateway_name == "generated-vgw"
    error_message = "generated virtual network gateway local should be used when no custom name is supplied"
  }

  assert {
    condition     = azurerm_virtual_network_gateway.vgw.location == "eastus2"
    error_message = "virtual network gateway should use the resource group location passthrough"
  }

  assert {
    condition     = azurerm_virtual_network_gateway.vgw.bgp_enabled == false
    error_message = "enable_vpn_bgp should map internally to bgp_enabled=false"
  }

  assert {
    condition     = length(azurerm_subnet.vgw) == 0
    error_message = "existing_gateway_subnet_id should skip GatewaySubnet creation"
  }

  assert {
    condition     = length(azurerm_route_table.vgw) == 0
    error_message = "enable_route_table_creation=false should skip route table creation"
  }

  assert {
    condition     = azurerm_virtual_network_gateway.vgw.tags.owner == "network" && azurerm_virtual_network_gateway.vgw.tags.env == "public" && azurerm_virtual_network_gateway.vgw.tags.workload == "hub"
    error_message = "default tags and add_tags should be merged on the virtual network gateway"
  }
}

run "custom_names_active_active_routes_and_connections" {
  command = plan

  variables {
    location                                     = "eastus2"
    environment                                  = "public"
    deploy_environment                           = "prod"
    workload_name                                = "spoke"
    org_name                                     = "contoso"
    existing_resource_group_name                 = "rg-existing"
    existing_virtual_network_name                = "vnet-spoke"
    existing_virtual_network_resource_group_name = "rg-existing"
    gateway_subnet_address_prefix                = "10.100.0.0/27"
    sku                                          = "VpnGw2"
    type                                         = "Vpn"
    custom_virtual_network_gateway_name          = "custom-vgw"
    custom_local_network_gateway_name            = "custom-lgw"
    route_table_name                             = "custom-rt"
    enable_vpn_active_active                     = true
    enable_vpn_bgp                               = true
    enable_vpn_private_ip_address                = true
    enable_route_table_creation                  = true
    enable_route_table_bgp_route_propagation     = false
    add_tags = {
      owner = "network"
    }
    route_table_tags = {
      purpose = "gateway"
    }
    ip_configurations = {
      primary = {
        ip_configuration_name = "ipconfig-primary"
        public_ip = {
          name = "pip-primary"
          sku  = "Standard"
          tags = {
            tier = "primary"
          }
        }
      }
      secondary = {
        public_ip = {
          name = ""
          sku  = "Standard"
        }
      }
    }
    local_network_gateways = {
      onprem = {
        name            = "onprem-lgw"
        gateway_address = "203.0.113.10"
        address_space   = ["10.10.0.0/16"]
        tags = {
          side = "onprem"
        }
        connection = {
          type           = "IPsec"
          name           = "onprem-conn"
          enable_bgp     = true
          routing_weight = 10
          shared_key     = "not-a-real-secret"
          tags = {
            conn = "vpn"
          }
        }
      }
    }
    express_route_circuits = {
      er1 = {
        id = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Network/expressRouteCircuits/erc-existing"
        connection = {
          name           = "erc-conn"
          routing_weight = 20
        }
        peering = {
          peering_type                  = "AzurePrivatePeering"
          vlan_id                       = 200
          peer_asn                      = 65010
          primary_peer_address_prefix   = "192.0.2.0/30"
          secondary_peer_address_prefix = "192.0.2.4/30"
        }
      }
    }
  }

  assert {
    condition     = azurerm_virtual_network_gateway.vgw.name == "custom-vgw"
    error_message = "custom virtual network gateway name should take precedence over generated names"
  }

  assert {
    condition     = local.virtual_network_gateway_name == "custom-vgw"
    error_message = "custom virtual network gateway local should take precedence over generated names"
  }

  assert {
    condition     = length(azurerm_subnet.vgw) == 1 && azurerm_subnet.vgw[0].address_prefixes[0] == "10.100.0.0/27"
    error_message = "omitting existing_gateway_subnet_id should create GatewaySubnet with the requested prefix"
  }

  assert {
    condition     = azurerm_virtual_network_gateway.vgw.active_active == true && length(azurerm_public_ip.vgw) == 2
    error_message = "active-active custom ip_configurations should produce two public IPs and enable active_active"
  }

  assert {
    condition     = azurerm_virtual_network_gateway.vgw.bgp_enabled == true && azurerm_virtual_network_gateway.vgw.private_ip_address_enabled == true
    error_message = "enable_vpn_bgp and enable_vpn_private_ip_address should map to azurerm 5.x attributes"
  }

  assert {
    condition     = azurerm_public_ip.vgw["primary"].name == "pip-primary" && azurerm_public_ip.vgw["secondary"].name == "custom-vgw-secondary-pip"
    error_message = "public IP custom names should win, while empty strings should fall through to generated names"
  }

  assert {
    condition     = azurerm_public_ip.vgw["primary"].tags.owner == "network" && azurerm_public_ip.vgw["primary"].tags.tier == "primary"
    error_message = "public IP tags should merge module default/add_tags with per-IP tags"
  }

  assert {
    condition     = azurerm_route_table.vgw[0].name == "custom-rt" && azurerm_route_table.vgw[0].bgp_route_propagation_enabled == false && azurerm_route_table.vgw[0].tags.purpose == "gateway"
    error_message = "route table creation, azurerm 5.x BGP propagation, custom naming, and tag merging should be honored"
  }

  assert {
    condition     = azurerm_local_network_gateway.vgw["onprem"].name == "onprem-lgw" && azurerm_local_network_gateway.vgw["onprem"].tags.side == "onprem"
    error_message = "local network gateway per-entry custom names and tags should be honored"
  }

  assert {
    condition     = azurerm_virtual_network_gateway_connection.vgw["onprem"].name == "onprem-conn" && azurerm_virtual_network_gateway_connection.vgw["onprem"].bgp_enabled == true && azurerm_virtual_network_gateway_connection.vgw["onprem"].tags.conn == "vpn"
    error_message = "local gateway connection names, enable_bgp compatibility input, and tags should map correctly"
  }

  assert {
    condition     = azurerm_virtual_network_gateway_connection.vgw["er1-erc"].express_route_circuit_id == var.express_route_circuits["er1"].id && azurerm_virtual_network_gateway_connection.vgw["er1-erc"].type == "ExpressRoute"
    error_message = "ExpressRoute connection should use the provided circuit ID and ExpressRoute type branch"
  }

  assert {
    condition     = azurerm_express_route_circuit_peering.vgw["er1"].express_route_circuit_name == "generated-erc" && azurerm_express_route_circuit_peering.vgw["er1"].peering_type == "AzurePrivatePeering"
    error_message = "ExpressRoute peering branch should use generated circuit name and configured peering type"
  }
}

run "empty_custom_names_fall_through" {
  command = plan

  variables {
    location                                     = "eastus2"
    environment                                  = "public"
    deploy_environment                           = "test"
    workload_name                                = "empty"
    org_name                                     = "contoso"
    existing_resource_group_name                 = "rg-existing"
    existing_virtual_network_name                = "vnet-empty"
    existing_virtual_network_resource_group_name = "rg-existing"
    existing_gateway_subnet_id                   = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-existing/providers/Microsoft.Network/virtualNetworks/vnet-empty/subnets/GatewaySubnet"
    sku                                          = "VpnGw1"
    type                                         = "Vpn"
    custom_virtual_network_gateway_name          = ""
    custom_local_network_gateway_name            = ""
    route_table_name                             = ""
    enable_route_table_creation                  = true
    local_network_gateways = {
      branch = {
        name            = ""
        gateway_address = "203.0.113.20"
        address_space   = ["10.20.0.0/16"]
      }
    }
  }

  assert {
    condition     = azurerm_virtual_network_gateway.vgw.name == "generated-vgw"
    error_message = "empty custom virtual network gateway name should fall through to the generated name"
  }

  assert {
    condition     = local.virtual_network_gateway_name == "generated-vgw"
    error_message = "empty custom virtual network gateway local should fall through to the generated name"
  }

  assert {
    condition     = azurerm_route_table.vgw[0].name == "generated-vgw-rt"
    error_message = "empty route_table_name should fall through to the generated route table name"
  }

  assert {
    condition     = azurerm_local_network_gateway.vgw["branch"].name == "generated-lgw-branch"
    error_message = "empty local network gateway entry name should fall through to the generated name"
  }
}
