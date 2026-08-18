variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "log_analytics_workspace_name" {
  type = string
}

variable "container_app_environment_name" {
  type = string
}

variable "container_app_name" {
  type = string
}

variable "acr_id" {
  description = "ID del ACR para asignar rol AcrPull."
  type        = string
}

variable "acr_login_server" {
  type = string
}

variable "use_acr_registry" {
  description = "true solo cuando la imagen ya está en ACR."
  type        = bool
}

variable "container_image" {
  description = "Imagen inicial (pública o del ACR)."
  type        = string
}

variable "target_port" {
  description = "Puerto del contenedor expuesto por ingress."
  type        = number
}

variable "min_replicas" {
  type = number
}

variable "max_replicas" {
  type = number
}

variable "cpu" {
  type = number
}

variable "memory" {
  description = "Memoria del contenedor, ej. 0.5Gi"
  type        = string
}

variable "tags" {
  type = map(string)
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = var.log_analytics_workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30

  tags = var.tags
}

resource "azurerm_container_app_environment" "this" {
  name                       = var.container_app_environment_name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this.id

  tags = var.tags
}

resource "azurerm_user_assigned_identity" "app" {
  name                = "id-${var.container_app_name}"
  location            = var.location
  resource_group_name = var.resource_group_name

  tags = var.tags
}

resource "azurerm_role_assignment" "acr_pull" {
  scope                = var.acr_id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.app.principal_id
}

resource "azurerm_container_app" "this" {
  name                         = var.container_app_name
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.app.id]
  }

  dynamic "registry" {
    for_each = var.use_acr_registry ? [1] : []
    content {
      server   = var.acr_login_server
      identity = azurerm_user_assigned_identity.app.id
    }
  }

  ingress {
    external_enabled = true
    target_port      = var.target_port
    transport        = "auto"

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = var.max_replicas

    container {
      name   = "api"
      image  = var.container_image
      cpu    = var.cpu
      memory = var.memory
    }
  }

  tags = var.tags

  depends_on = [azurerm_role_assignment.acr_pull]
}

output "environment_id" {
  value = azurerm_container_app_environment.this.id
}

output "environment_name" {
  value = azurerm_container_app_environment.this.name
}

output "container_app_id" {
  value = azurerm_container_app.this.id
}

output "container_app_name" {
  value = azurerm_container_app.this.name
}

output "fqdn" {
  value = azurerm_container_app.this.ingress[0].fqdn
}

output "identity_principal_id" {
  value = azurerm_user_assigned_identity.app.principal_id
}
