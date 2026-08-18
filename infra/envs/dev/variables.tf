variable "location" {
  type = string
}

variable "resource_group_name" {
  description = "RG existente del bootstrap."
  type        = string
}

variable "acr_name" {
  description = "Nombre globalmente único del ACR (solo alfanumérico)."
  type        = string
}

variable "acr_sku" {
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

variable "use_acr_registry" {
  description = "true solo cuando la imagen ya está en ACR."
  type        = bool
}

variable "container_image" {
  description = "Imagen inicial. Hasta tener la de Go en ACR, usa la de ejemplo de Microsoft."
  type        = string
}

variable "target_port" {
  type = number
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
  type = string
}

variable "tags" {
  type = map(string)
}
