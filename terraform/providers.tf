#
# Provider Configuration
#

terraform {
  required_version = ">= 0.11.10"
}

provider "azurerm" {
  version = ">= 1.18.0"
  client_id = "${var.client_id}"
  client_secret = "${var.client_secret}"
  tenant_id = "${var.tenant_id}"
  subscription_id = "${var.subscription_id}"  
}
