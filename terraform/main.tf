resource "azurerm_resource_group" "example" {
  name     = "tranzact-challenge-resources"
  location = "East US"
}

resource "azurerm_service_plan" "example" {
  name                = "tranzact-challenge-sp"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  os_type             = "Linux"
  sku_name            = "S1"
}


resource "azurerm_linux_web_app" "example" {
  name                = "tranzact-challenge-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  service_plan_id     = azurerm_service_plan.example.id

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }
}

resource "azurerm_linux_web_app_slot" "slot-qas" {
  name           = "tranzact-challenge-qas"
  app_service_id = azurerm_linux_web_app.example.id

  site_config {}
}

resource "azurerm_linux_web_app_slot" "slot-dev" {
  name           = "tranzact-challenge-dev"
  app_service_id = azurerm_linux_web_app.example.id

  site_config {}
}

resource "azurerm_app_service_source_control" "example" {
  app_id        = azurerm_linux_web_app.example.id
  use_local_git = true
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "workspace-test"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "example" {
  name                = "tf-test-appinsights"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  workspace_id        = azurerm_log_analytics_workspace.example.id
  application_type    = "Node.JS"
}