variable "location" {
  description = "Región de Azure (ej. eastus, westus2, brazilsouth)."
  type        = string
}

variable "resource_group_name" {
  description = "Nombre del Resource Group del bootstrap."
  type        = string
}

variable "storage_account_name" {
  description = "Nombre globalmente único del Storage Account (3-24 chars, solo a-z y 0-9)."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9]{3,24}$", var.storage_account_name))
    error_message = "storage_account_name: 3-24 caracteres, solo minúsculas y números."
  }
}

variable "storage_container_name" {
  description = "Nombre del contenedor blob para el tfstate."
  type        = string
}

variable "key_vault_name" {
  description = "Nombre globalmente único del Key Vault (3-24 chars, alfanumérico y guiones)."
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z][a-zA-Z0-9-]{1,22}[a-zA-Z0-9]$", var.key_vault_name))
    error_message = "key_vault_name inválido. Debe tener 3-24 chars, empezar con letra y no terminar en guion."
  }
}

variable "tags" {
  description = "Tags para todos los recursos."
  type        = map(string)
}
