terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-backend-rg"
    storage_account_name = "tfjenkinsstate"
    container_name       = "tfstate"
    key                  = "jenkinsvm.tfstate"
  }
}
