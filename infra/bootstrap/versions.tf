terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # El bootstrap usa estado LOCAL a propósito.
  # Este stack crea el Storage Account que luego usarán
  # infra/envs/dev (y otros entornos) como backend remoto.
}
