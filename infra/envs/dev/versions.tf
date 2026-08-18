terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  # Backend parcial: los valores van en backend.hcl (local, no se sube a Git).
  backend "azurerm" {}
}
