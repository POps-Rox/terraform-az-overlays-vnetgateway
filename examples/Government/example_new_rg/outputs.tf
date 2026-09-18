# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

output "test_public_ip_address_id" {
  value       = module.mod_example.public_ip_addresses["001"].id
  description = "The ID of the Public IP Address"
}

output "test_virtual_network_gateway_id" {
  value       = module.mod_example.virtual_network_gateway.id
  description = "The ID of the Virtual Network Gateway"
}
