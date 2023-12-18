terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  backend "azurerm" {
      resource_group_name  = "test-rg"
      storage_account_name = "testasarilke"
      container_name       = "dev-tfstate"
      key                  = "terraform.tfstate"
  }

}
provider "azurerm" {
  features {}
}