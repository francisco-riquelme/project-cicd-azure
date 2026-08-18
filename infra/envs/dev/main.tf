data "azurerm_resource_group" "this" {
  name = var.resource_group_name
}

module "acr" {
  source = "../../modules/acr"

  name                = var.acr_name
  resource_group_name = data.azurerm_resource_group.this.name
  location            = var.location
  sku                 = var.acr_sku
  tags                = var.tags
}

module "container_apps" {
  source = "../../modules/container-apps"

  resource_group_name            = data.azurerm_resource_group.this.name
  location                       = var.location
  log_analytics_workspace_name   = var.log_analytics_workspace_name
  container_app_environment_name = var.container_app_environment_name
  container_app_name             = var.container_app_name
  acr_id                         = module.acr.id
  acr_login_server               = module.acr.login_server
  use_acr_registry               = var.use_acr_registry
  container_image                = var.container_image
  target_port                    = var.target_port
  min_replicas                   = var.min_replicas
  max_replicas                   = var.max_replicas
  cpu                            = var.cpu
  memory                         = var.memory
  tags                           = var.tags
}
