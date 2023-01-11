resource "azurerm_resource_group" "example" {
  name     = "$PREFIX-resources"
  location = "$LOCATION"
}

resource "azurerm_service_plan" "example" {
  name                = "$PREFIX-sp"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  os_type             = "Linux"
  sku_name            = "S1"
}


resource "azurerm_linux_web_app" "example" {
  name                = "$PREFIX-example"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  service_plan_id     = azurerm_service_plan.example.id

  site_config {
    application_stack {
      php_version = "8.0"
    }
  }
}

resource "azurerm_linux_web_app_slot" "slot-qas" {
  name           = "$PREFIX-qas"
  app_service_id = azurerm_linux_web_app.example.id

  site_config {}
}

resource "azurerm_linux_web_app_slot" "slot-dev" {
  name           = "$PREFIX-dev "
  app_service_id = azurerm_linux_web_app.example.id

  site_config {}
}

resource "azurerm_app_service_source_control" "example" {
  app_id        = azurerm_linux_web_app.example.id
  use_local_git = true
}