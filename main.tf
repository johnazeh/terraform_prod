# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }

  required_version = ">= 1.1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "PROD-RG"
  location = "CanadaCentral"
}

resource "azurerm_sql_server" "sql" {
  name                         = "trudev"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = "CanadaCentral"
  version                      = "12.0"
  administrator_login          = "john.azeh"
  administrator_login_password = "Password010101"
}

resource "azurerm_sql_firewall_rule" "sql" {
  name                = "AlllowAzureServices"
  resource_group_name = azurerm_resource_group.rg.name
  server_name         = azurerm_sql_server.sql.name
  start_ip_address    = "108.173.224.177"
  end_ip_address      = "108.173.224.177"
}

resource "azurerm_sql_database" "sql" {
  name                             = "promodb"
  resource_group_name              = azurerm_resource_group.rg.name
  location                         = "CanadaCentral"
  server_name                      = azurerm_sql_server.sql.name
  edition                          = "Standard"
  requested_service_objective_name = "S1"
}

resource "azurerm_storage_account" "stor" {
  name                     = "prodstorcc01"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_storage_container" "cont" {
  name                  = "prodconcc01"
  storage_account_name  = azurerm_storage_account.stor.name
  container_access_type = "private"
}
