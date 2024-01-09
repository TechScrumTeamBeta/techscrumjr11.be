provider "azurerm" {
  version = "2.0"
}

locals {
  resource_group_name = "techscrum-cluster-rg"
  aks_cluster_name    = "techscrum-cluster"
  location            = "australiasoutheast"
  network_cidr        = "10.1.0.0/16"
  subnet_cidr_1       = "10.1.1.0/24"
  subnet_cidr_2       = "10.1.2.0/24"
  node_count          = 2
}

resource "azurerm_resource_group" "aks-cluster" {
  name     = local.resource_group_name
  location = local.location
}

resource "azurerm_virtual_network" "aks-vnet" {
  name                = "aks-vnet"
  address_space       = [local.network_cidr]
  location            = local.location
  resource_group_name = local.resource_group_name
}

resource "azurerm_subnet" "aks-subnet-1" {
  name                 = "aks-subnet-1"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks-vnet.name
  address_prefix       = local.subnet_cidr_1
}

resource "azurerm_subnet" "aks-subnet-2" {
  name                 = "aks-subnet-2"
  resource_group_name  = local.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks-vnet.name
  address_prefix       = local.subnet_cidr_2
}

resource "azurerm_kubernetes_cluster" "aks-cluster" {
  name                = local.aks_cluster_name
  location            = local.location
  resource_group_name = local.resource_group_name
  dns_prefix          = "${local.aks_cluster_name}-dns"

  default_node_pool {
    name            = "default"
    count           = local.node_count
    vm_size         = "Standard_D2as_v4"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }
  service_principal {
    client_id     = "<service principal client ID>"
    client_secret = "<service principal secret>"
  }
  depends_on = [azurerm_subnet.aks-subnet-1, azurerm_subnet.aks-subnet-2]
}
