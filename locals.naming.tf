locals {
  # Naming locals/constants
  name_prefix = lower(var.name_prefix)
  name_suffix = lower(var.name_suffix)

  resource_group_name          = element(coalescelist(data.azurerm_resource_group.rgrp.*.name, module.mod_scaffold_rg.*.resource_group_name, [""]), 0)
  location                     = element(coalescelist(data.azurerm_resource_group.rgrp.*.location, module.mod_scaffold_rg.*.resource_group_location, [""]), 0)
  virtual_network_gateway_name = coalesce(var.custom_virtual_network_gateway_name, data.popsrox_resource_name.virtual_network_gateway.result)
  local_network_gateway_name   = coalesce(var.custom_local_network_gateway_name, data.popsrox_resource_name.local_network_gateway.result)
  express_route_circuit_name   = coalesce(var.custom_express_route_circuit_name, data.popsrox_resource_name.express_route_circuit.result)
}
