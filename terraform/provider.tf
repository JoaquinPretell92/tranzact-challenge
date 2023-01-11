terraform {
  backend "azurerm" {
    resource_group_name  = "tranzact-challenge"
    storage_account_name = "tranzactchallengestr"
    container_name       = "tranzact-challenge-tfstates"
    key                  = "terraform-tranzact-challenge.tfstate"
  }
}

provider "azurerm" {
  # The "feature" block is required for AzureRM provider 2.x.
  # If you're using version 1.x, the "features" block is not allowed.
  features {}
  skip_provider_registration = true
}

data "azurerm_client_config" "current" {}