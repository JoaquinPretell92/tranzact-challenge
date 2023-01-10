output "repository_url" {
  value = "https://${local.scm_username}:${local.scm_password}@${local.repo_uri}/${azurerm_linux_web_app.example.name}.git"
}

output "app_name" {
  value = azurerm_linux_web_app.example.default_hostname
}