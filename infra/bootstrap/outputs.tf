output "resource_group_name" {
  description = "Resource Group del bootstrap."
  value       = azurerm_resource_group.bootstrap.name
}

output "location" {
  description = "Región usada."
  value       = azurerm_resource_group.bootstrap.location
}

output "storage_account_name" {
  description = "Storage Account del tfstate remoto (usar en backend de envs/dev)."
  value       = azurerm_storage_account.tfstate.name
}

output "storage_container_name" {
  description = "Contenedor blob del tfstate."
  value       = azurerm_storage_container.tfstate.name
}

output "key_vault_name" {
  description = "Key Vault del proyecto."
  value       = azurerm_key_vault.main.name
}

output "key_vault_uri" {
  description = "URI del Key Vault."
  value       = azurerm_key_vault.main.vault_uri
}

output "backend_config_hint" {
  description = "Valores listos para el backend remoto de infra/envs/dev."
  value       = <<-EOT
    resource_group_name  = "${azurerm_resource_group.bootstrap.name}"
    storage_account_name = "${azurerm_storage_account.tfstate.name}"
    container_name       = "${azurerm_storage_container.tfstate.name}"
    key                  = "dev/terraform.tfstate"
  EOT
}
