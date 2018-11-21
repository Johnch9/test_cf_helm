resource "azurerm_resource_group" "api_security" {
    name     = "${var.api_rg}"
    location = "${var.location}"
}

resource "azurerm_network_security_group" "api_security_nsg" {
    name                = "${var.api_nsg}"
    location            = "${azurerm_resource_group.api_security.location}"
    resource_group_name = "${azurerm_resource_group.api_security.name}"
}

resource "azurerm_network_security_rule" "api_nsg_comm_to_api_mgmnt" {
    name                   = "CommToAPIMgnt"
    priority               = "150"
    source_port_range      = "*",
    source_address_prefix  = "Internet",
    destination_address_prefix = "VirtualNetwork",
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "tcp"
    destination_port_ranges =  ["80","443"]
    description            = "Client communication to API Management"
    resource_group_name         = "${azurerm_resource_group.api_security.name}"
    network_security_group_name = "${azurerm_network_security_group.api_security_nsg.name}"
}

resource "azurerm_network_security_rule" "api_nsg_post_3443" {
    name                   = "Port_3443"
    priority               = "160"
    source_port_range      = "*",
    source_address_prefix  = "ApiManagement",
    destination_address_prefix = "VirtualNetwork",
    direction              = "Inbound"
    access                 = "Allow"
    protocol               = "tcp"
    destination_port_range = "3443"
    description            = "Management endpoint for Azure portal and Powershell"
    resource_group_name         = "${azurerm_resource_group.api_security.name}"
    network_security_group_name = "${azurerm_network_security_group.api_security_nsg.name}"
}
