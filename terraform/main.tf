resource "azurerm_resource_group" "rsc" {
  name     = "tranzact-challenge-resources"
  location = "East US"
}

resource "azurerm_service_plan" "asp" {
  name                = "tranzact-challenge-sp"
  location            = azurerm_resource_group.rsc.location
  resource_group_name = azurerm_resource_group.rsc.name
  os_type             = "Linux"
  sku_name            = "S1"
}


resource "azurerm_linux_web_app" "alwp" {
  name                = "tranzact-challenge-prd"
  location            = azurerm_resource_group.rsc.location
  resource_group_name = azurerm_resource_group.rsc.name
  service_plan_id     = azurerm_service_plan.asp.id

  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }


}

resource "azurerm_linux_web_app_slot" "slot-qas" {
  name           = "tranzact-challenge-qas"
  app_service_id = azurerm_linux_web_app.alwp.id

  site_config {}
}

resource "azurerm_linux_web_app_slot" "slot-dev" {
  name           = "tranzact-challenge-dev"
  app_service_id = azurerm_linux_web_app.alwp.id

  site_config {}
}

resource "azurerm_app_service_source_control" "alwpc" {
  app_id        = azurerm_linux_web_app.alwp.id
  use_local_git = true
}

resource "azurerm_log_analytics_workspace" "alaw" {
  name                = "tranzact-challenge-workspace"
  location            = azurerm_resource_group.rsc.location
  resource_group_name = azurerm_resource_group.rsc.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_application_insights" "aai" {
  name                = "tranzact-challenge-app-insight"
  location            = azurerm_resource_group.rsc.location
  resource_group_name = azurerm_resource_group.rsc.name
  workspace_id        = azurerm_log_analytics_workspace.alaw.id
  application_type    = "Node.JS"

}

resource "azurerm_application_insights_web_test" "aait" {
  name                    = "tf-test-appinsights-webtest"
  location                = azurerm_application_insights.aai.location
  resource_group_name     = azurerm_resource_group.rsc.name
  application_insights_id = azurerm_application_insights.aai.id
  kind                    = "ping"
  frequency               = 300
  timeout                 = 60
  enabled                 = true
  geo_locations           = ["us-tx-sn1-azr", "us-il-ch1-azr"]

  configuration = <<XML
<WebTest Name="tranzact-challenge-example" Id="ABD48585-0831-40CB-9069-682EA6BB3583" Enabled="True" CssProjectStructure="" CssIteration="" Timeout="0" WorkItemIds="" xmlns="http://microsoft.com/schemas/VisualStudio/TeamTest/2010" Description="" CredentialUserName="" CredentialPassword="" PreAuthenticate="True" Proxy="default" StopOnError="False" RecordedResultFile="" ResultsLocale="">
  <Items>
    <Request Method="GET" Guid="a5f10126-e4cd-570d-961c-cea43999a200" Version="1.1" Url="https://tranzact-challenge-example.azurewebsites.net" ThinkTime="0" Timeout="300" ParseDependentRequests="True" FollowRedirects="True" RecordResult="True" Cache="False" ResponseTimeGoal="0" Encoding="utf-8" ExpectedHttpStatusCode="200" ExpectedResponseUrl="" ReportingName="" IgnoreHttpStatusCode="False" />
  </Items>
</WebTest>
XML

}

resource "azurerm_monitor_action_group" "main" {
  name                = "tranzact-challene-action-group"
  resource_group_name = azurerm_resource_group.rsc.name
  short_name          = "prdAlert"
  email_receiver {
    name                    = "SendToAdmin"
    email_address           = "joaquin.pretell@tecsup.edu.pe"
    use_common_alert_schema = true
  }
}

resource "azurerm_monitor_metric_alert" "maina" {
  name                = "tranzact-challenge-metric-alert"
  resource_group_name = azurerm_resource_group.rsc.name
  scopes              = [azurerm_application_insights_web_test.aait.id, data.azurerm_application_insights.example.id]
  description         = "PING test alert"

  application_insights_web_test_location_availability_criteria {
    web_test_id       = azurerm_application_insights_web_test.aait.id
    component_id      = data.azurerm_application_insights.example.id
    failed_location_count = 2
  }

  action {
    action_group_id = azurerm_monitor_action_group.main.id
  }
}