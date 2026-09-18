
resource "azurerm_local_network_gateway" "vgw" {
  for_each = local.local_network_gateways

  location            = var.location
  name                = try(trimspace(each.value.name), "") != "" ? each.value.name : "${local.local_network_gateway_name}-${each.key}"
  resource_group_name = try(local.resource_group_name, var.existing_virtual_network_resource_group_name)
  address_space       = each.value.address_space
  gateway_address     = each.value.gateway_address
  gateway_fqdn        = each.value.gateway_fqdn
  tags                = merge(local.default_tags, each.value.tags)

  dynamic "bgp_settings" {
    for_each = each.value.bgp_settings == null ? [] : ["BgpSettings"]

    content {
      asn                 = each.value.bgp_settings.asn
      bgp_peering_address = each.value.bgp_settings.bgp_peering_address
      peer_weight         = each.value.bgp_settings.peer_weight
    }
  }
}
