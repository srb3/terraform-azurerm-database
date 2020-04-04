resource "azurerm_sql_database" "db" {
  name                             = var.db_name
  resource_group_name              = var.resource_group_name
  location                         = var.location
  edition                          = var.db_edition
  collation                        = var.collation
  server_name                      = azurerm_sql_server.server.name
  create_mode                      = "Default"
  requested_service_objective_name = var.service_objective_name
  tags                             = var.tags
}

resource "azurerm_sql_server" "server" {
  name                         = "${var.db_name}-sqlsvr"
  resource_group_name          = var.resource_group_name
  location                     = var.location
  version                      = var.server_version
  administrator_login          = var.sql_admin_username
  administrator_login_password = var.sql_password
  tags                         = var.tags
}

resource "azurerm_sql_firewall_rule" "fw" {
  for_each = var.sql_firewall_rules
    name                = "${var.db_name}-${each.key}-fwrules"
    resource_group_name = var.resource_group_name
    server_name         = azurerm_sql_server.server.name
    start_ip_address    = each.key
    end_ip_address      = each.value
}

resource "azurerm_sql_virtual_network_rule" "sqlvnetrule" {
  count               = length(var.sql_vnet_rules)
  name                = "${var.db_name}-${count.index}"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.server.name
  subnet_id           = var.sql_vnet_rules[count.index]
}
