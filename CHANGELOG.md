# v2.0.0 - 2026-05-11

Changed
- **BREAKING**: Upgrade `azurerm` provider to `~> 4.20` (was `~> 3.116`).
- **BREAKING**: Raise minimum Terraform CLI to `>= 1.10` (was `>= 1.9`).
- Declare `azapi ~> 2.0` provider for fleet alignment.
- Examples now pin matching provider versions and add a `subscription_id` env-var hint
  (azurerm 4.x requires `ARM_SUBSCRIPTION_ID` for an apply; not required for `validate`).

Notes
- No resource-attribute renames required in this overlay (no `azurerm_storage_account`,
  `azurerm_key_vault`, or `azurerm_monitor_diagnostic_setting` blocks).
- Cross-module dependency: consumers must also have updated transitive overlays
  (`tf-az-overlays-azregionslookup`, `tf-az-overlays-resourcegroup`) to `azurerm ~> 4.x`
  before this version can be used with `terraform init -upgrade`.

# v1.0.0 - <date>

Added
- Add Something you added
