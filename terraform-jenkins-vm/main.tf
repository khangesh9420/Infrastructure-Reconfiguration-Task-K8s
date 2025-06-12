provider "azurerm" {
  features {}
  subscription_id = "82cd7676-6937-4ad1-b91f-bbafc1bc0f4c"
}

# -----------------------------
# Network Interface for VM
# -----------------------------
resource "azurerm_network_interface" "nic" {
  name                = "k8jenkismaster861_z1"
  location            = "northeurope"
  resource_group_name = "jenkins-rg"

  ip_configuration {
    name                          = "ipconfig1"
    subnet_id                     = "/subscriptions/82cd7676-6937-4ad1-b91f-bbafc1bc0f4c/resourceGroups/jenkins-rg/providers/Microsoft.Network/virtualNetworks/K8jenkismaster-vnet/subnets/default"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "/subscriptions/82cd7676-6937-4ad1-b91f-bbafc1bc0f4c/resourceGroups/jenkins-rg/providers/Microsoft.Network/publicIPAddresses/K8jenkismaster-ip"
  }
}

# -----------------------------
# Linux VM for Jenkins
# -----------------------------
resource "azurerm_linux_virtual_machine" "vm" {
  name                  = "K8jenkismaster"
  resource_group_name   = "jenkins-rg"
  location              = "northeurope"
  size                  = "Standard_B1s"
  zone                  = "1"
  network_interface_ids = [azurerm_network_interface.nic.id]
  admin_username        = "azureuser"

  secure_boot_enabled = true
  vtpm_enabled        = true

  os_disk {
    name                 = "K8jenkismaster_disk1_92f7f91d5593427c81dd9d1bbe78105f"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  lifecycle {
    ignore_changes = [
      admin_ssh_key,
      source_image_reference,
      os_disk,
      boot_diagnostics,
      additional_capabilities,
      tags
    ]
  }
}

# -----------------------------
# Azure Kubernetes Service (AKS)
# -----------------------------
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "jenkins-aks"
  location            = "centralus"
  resource_group_name = "jenkins-rg"
  dns_prefix          = "jenkins-ak-jenkins-rg-82cd76"

  kubernetes_version = "1.31.8"

  default_node_pool {
    name                 = "nodepool1"
    node_count           = 1
    vm_size              = "Standard_D4ds_v5"
    max_pods             = 250
    os_disk_type         = "Ephemeral"
    kubelet_disk_type    = "OS"
    orchestrator_version = "1.31.8"
  }

  identity {
    type = "SystemAssigned"
  }

  linux_profile {
    admin_username = "azureuser"

    ssh_key {
      key_data = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRwwPxzsxJl5dkfPQ4FGpe9dM0shUjrs71FIWQkjtAdO6oTOIxqs9beDf83cawWR7+rkkjyFrYmJ1ZGyE0X0BH2QtjJR26NvGC1OWTE24wR83akKZcc4PMb63CyrIPRBntViGJK7hnOuiJM0OkfUZ4DoOj/H1Bqj7LOHWtIQJEZ0U5r96VnAbgnmcNvZOyEbTRgcwG0aGOQ3IkOjDpqxdzW/ZhbBkio4C+mkeAJjmS6CMyhA1yuFYPzvq+DffTvC0bjPPJQMx/0wbyKxlB80l8DketslvNbU+ttrYdMogSnYDo32aBs9mgHJbkeDSVZQIkdxTjHizxyZNbcI807yWl"
    }
  }

  tags = {
    environment = "devops"
  }

  lifecycle {
    ignore_changes = [
      kubernetes_version,
      default_node_pool[0].orchestrator_version,
      default_node_pool[0].upgrade_settings,
      tags
    ]
  }
}

