# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#---------------------------------------------------------------
# Virtual Network Gateway Resource
#---------------------------------------------------------------

resource "azurerm_virtual_network_gateway" "vgw" {
  location                   = local.location
  name                       = local.virtual_network_gateway_name
  resource_group_name        = var.existing_virtual_network_resource_group_name != "" ? var.existing_virtual_network_resource_group_name : local.resource_group_name
  sku                        = var.sku
  type                       = var.type
  active_active              = var.enable_vpn_active_active
  edge_zone                  = var.edge_zone
  bgp_enabled                = var.enable_vpn_bgp
  generation                 = var.vpn_generation
  private_ip_address_enabled = var.enable_vpn_private_ip_address
  tags                       = local.default_tags
  vpn_type                   = var.vpn_type

  dynamic "ip_configuration" {
    for_each = local.gateway_ip_configurations

    content {
      public_ip_address_id          = azurerm_public_ip.vgw[ip_configuration.key].id
      subnet_id                     = try(azurerm_subnet.vgw[0].id, var.existing_gateway_subnet_id)
      name                          = ip_configuration.value.name
      private_ip_address_allocation = ip_configuration.value.private_ip_address_allocation
    }
  }
  dynamic "bgp_settings" {
    for_each = local.bgp_settings

    content {
      asn         = bgp_settings.value.asn
      peer_weight = bgp_settings.value.peer_weight

      dynamic "peering_addresses" {
        for_each = bgp_settings.value.peering_addresses

        content {
          apipa_addresses       = peering_addresses.value.apipa_addresses
          ip_configuration_name = peering_addresses.value.ip_configuration_name
        }
      }
    }
  }
  dynamic "vpn_client_configuration" {
    for_each = var.vpn_point_to_site == null ? [] : ["VpnClientConfiguration"]

    content {
      address_space         = var.vpn_point_to_site.address_space
      aad_audience          = var.vpn_point_to_site.aad_audience
      aad_issuer            = var.vpn_point_to_site.aad_issuer
      aad_tenant            = var.vpn_point_to_site.aad_tenant
      radius_server_address = var.vpn_point_to_site.radius_server_address
      radius_server_secret  = var.vpn_point_to_site.radius_server_secret
      vpn_auth_types        = var.vpn_point_to_site.vpn_auth_types
      vpn_client_protocols  = var.vpn_point_to_site.vpn_client_protocols

      dynamic "revoked_certificate" {
        for_each = var.vpn_point_to_site.revoked_certificate

        content {
          name       = revoked_certificate.value.name
          thumbprint = revoked_certificate.value.thumbprint
        }
      }
      dynamic "root_certificate" {
        for_each = var.vpn_point_to_site.root_certificate

        content {
          name             = root_certificate.value.name
          public_cert_data = root_certificate.value.public_cert_data
        }
      }
    }
  }

  depends_on = [
    azurerm_subnet.vgw,
    azurerm_public_ip.vgw
  ]
}

resource "azurerm_virtual_network_gateway_connection" "vgw" {
  for_each = local.virtual_network_gateway_connections

  location                           = var.location
  name                               = coalesce(each.value.name, "${local.virtual_network_gateway_name}-${each.key}-vngc")
  resource_group_name                = var.existing_virtual_network_resource_group_name != "" ? var.existing_virtual_network_resource_group_name : local.resource_group_name
  type                               = each.value.type
  virtual_network_gateway_id         = azurerm_virtual_network_gateway.vgw.id
  authorization_key                  = try(each.value.authorization_key, null)
  connection_mode                    = try(each.value.connection_mode, null)
  connection_protocol                = try(each.value.connection_protocol, null)
  dpd_timeout_seconds                = try(each.value.dpd_timeout_seconds, null)
  egress_nat_rule_ids                = try(each.value.egress_nat_rule_ids, null)
  bgp_enabled                        = try(each.value.enable_bgp, null)
  express_route_circuit_id           = try(each.value.express_route_circuit_id, null)
  express_route_gateway_bypass       = try(each.value.express_route_gateway_bypass, null)
  ingress_nat_rule_ids               = try(each.value.ingress_nat_rule_ids, null)
  local_azure_ip_address_enabled     = try(each.value.local_azure_ip_address_enabled, null)
  local_network_gateway_id           = try(azurerm_local_network_gateway.vgw[trimprefix(each.key, "-lgw")].id, each.value.local_network_gateway_id, null)
  peer_virtual_network_gateway_id    = try(each.value.peer_virtual_network_gateway_id, null)
  routing_weight                     = each.value.routing_weight
  shared_key                         = try(each.value.shared_key, null)
  tags                               = merge(local.default_tags, try(each.value.tags, {}))
  use_policy_based_traffic_selectors = try(each.value.use_policy_based_traffic_selectors, null)

  dynamic "custom_bgp_addresses" {
    for_each = try(each.value.custom_bgp_addresses, null) == null ? [] : ["CustomBgpAddresses"]

    content {
      primary   = each.value.custom_bgp_addresses.primary
      secondary = each.value.custom_bgp_addresses.secondary
    }
  }
  dynamic "ipsec_policy" {
    for_each = try(each.value.ipsec_policy, null) == null ? [] : ["IPSecPolicy"]

    content {
      dh_group         = each.value.ipsec_policy.dh_group
      ike_encryption   = each.value.ipsec_policy.ike_encryption
      ike_integrity    = each.value.ipsec_policy.ike_integrity
      ipsec_encryption = each.value.ipsec_policy.ipsec_encryption
      ipsec_integrity  = each.value.ipsec_policy.ipsec_integrity
      pfs_group        = each.value.ipsec_policy.pfs_group
      sa_datasize      = each.value.ipsec_policy.sa_datasize
      sa_lifetime      = each.value.ipsec_policy.sa_lifetime
    }
  }
  dynamic "traffic_selector_policy" {
    for_each = try(each.value.traffic_selector_policy, null) == null ? [] : each.value.traffic_selector_policy

    content {
      local_address_cidrs  = traffic_selector_policy.value.local_address_prefixes
      remote_address_cidrs = traffic_selector_policy.value.remote_address_prefixes
    }
  }

  depends_on = [
    azurerm_local_network_gateway.vgw,
    azurerm_virtual_network_gateway.vgw,
  ]
}
