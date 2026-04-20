# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#------------------------------------------------------------
# Azure NoOps Naming - This should be used on all resource naming
#------------------------------------------------------------
data "popsrox_resource_name" "virtual_network_gateway" {
  name          = var.workload_name
  resource_type = "azurerm_virtual_network_gateway"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azure_region_lookup.location_short : var.location]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "vgw"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "popsrox_resource_name" "local_network_gateway" {
  name          = var.workload_name
  resource_type = "azurerm_local_network_gateway"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azure_region_lookup.location_short : var.location]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "lgw"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}

data "popsrox_resource_name" "express_route_circuit" {
  name          = var.workload_name
  resource_type = "azurerm_express_route_circuit"
  prefixes      = [var.org_name, var.use_location_short_name ? module.mod_azure_region_lookup.location_short : var.location]
  suffixes      = compact([var.name_prefix == "" ? null : local.name_prefix, var.deploy_environment, local.name_suffix, var.use_naming ? "" : "lgw"])
  use_slug      = var.use_naming
  clean_input   = true
  separator     = "-"
}
