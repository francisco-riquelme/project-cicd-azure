output "acr_name" {
  value = module.acr.name
}

output "acr_login_server" {
  value = module.acr.login_server
}

output "container_app_fqdn" {
  value = module.container_apps.fqdn
}

output "container_app_name" {
  value = module.container_apps.container_app_name
}

output "container_app_environment_name" {
  value = module.container_apps.environment_name
}
