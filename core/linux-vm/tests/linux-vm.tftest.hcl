mock_provider "azurerm" {
  mock_resource "azurerm_network_interface" {
    defaults = {
      id                 = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/vm-rg/providers/Microsoft.Network/networkInterfaces/proxy-nic"
      private_ip_address = "10.0.1.4"
    }
  }

  mock_resource "azurerm_public_ip" {
    defaults = {
      id         = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/vm-rg/providers/Microsoft.Network/publicIPAddresses/proxy-pip"
      ip_address = "203.0.113.42"
    }
  }
}

variables {
  name                = "proxy"
  resource_group_name = "vm-rg"
  location            = "westeurope"
  subnet_id           = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/network-rg/providers/Microsoft.Network/virtualNetworks/hub/subnets/workloads"
  size                = "Standard_B2s"
  admin_username      = "azureadmin"
  ssh_public_key      = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPItfVFmCLJWaz+oRaN/47vEpjCtn8WVW0WYR2YAzdpW"
  source_image_id     = "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/image-rg/providers/Microsoft.Compute/images/proxy"
  tags                = { environment = "test" }
}

run "private_packer_vm" {
  command = apply

  assert {
    condition = (
      azurerm_linux_virtual_machine.this.source_image_id == var.source_image_id &&
      azurerm_linux_virtual_machine.this.disable_password_authentication &&
      one(azurerm_linux_virtual_machine.this.admin_ssh_key).public_key == var.ssh_public_key &&
      azurerm_linux_virtual_machine.this.network_interface_ids[0] == output.network_interface_id
    )
    error_message = "The private VM must use the Packer image, SSH key, and created NIC."
  }

  assert {
    condition = (
      azurerm_network_interface.this.ip_configuration[0].subnet_id == var.subnet_id &&
      azurerm_network_interface.this.resource_group_name == "vm-rg" &&
      output.private_ip_address == "10.0.1.4" &&
      output.public_ip_address == null &&
      length(azurerm_public_ip.this) == 0 &&
      azurerm_linux_virtual_machine.this.tags["environment"] == "test" &&
      azurerm_network_interface.this.tags["environment"] == "test"
    )
    error_message = "The NIC must join the supplied subnet, use the requested resource group, and default to no public IP."
  }
}

run "marketplace_vm_with_public_ip" {
  command = apply

  variables {
    source_image_id = null
    marketplace_image = {
      publisher = "Canonical"
      offer     = "0001-com-ubuntu-server-jammy"
      sku       = "22_04-lts-gen2"
      version   = "22.04.202501010"
    }
    public_ip = { name = "proxy-pip" }
  }

  assert {
    condition = (
      azurerm_linux_virtual_machine.this.source_image_reference[0].publisher == "Canonical" &&
      azurerm_linux_virtual_machine.this.source_image_reference[0].version == "22.04.202501010" &&
      azurerm_public_ip.this["main"].sku == "Standard" &&
      azurerm_public_ip.this["main"].allocation_method == "Static" &&
      azurerm_public_ip.this["main"].tags["environment"] == "test" &&
      azurerm_network_interface.this.ip_configuration[0].public_ip_address_id == azurerm_public_ip.this["main"].id &&
      output.public_ip_address == "203.0.113.42"
    )
    error_message = "The Marketplace VM must use its selected image and optional Standard public IP."
  }
}

run "packer_image_with_purchase_plan" {
  command = plan

  variables {
    marketplace_plan = {
      publisher = "example"
      product   = "product"
      name      = "plan"
    }
  }

  assert {
    condition = (
      azurerm_linux_virtual_machine.this.source_image_id == var.source_image_id &&
      azurerm_linux_virtual_machine.this.plan[0].name == "plan" &&
      azurerm_linux_virtual_machine.this.plan[0].product == "product" &&
      azurerm_linux_virtual_machine.this.plan[0].publisher == "example"
    )
    error_message = "A Packer image derived from a Marketplace image must support its purchase plan."
  }
}

run "reject_missing_image" {
  command = plan

  variables {
    source_image_id = null
  }

  expect_failures = [azurerm_linux_virtual_machine.this]
}

run "reject_two_images" {
  command = plan

  variables {
    marketplace_image = {
      publisher = "Canonical"
      offer     = "ubuntu"
      sku       = "example"
      version   = "latest"
    }
  }

  expect_failures = [azurerm_linux_virtual_machine.this]
}

run "reject_blank_ssh_key" {
  command = plan

  variables {
    ssh_public_key = " "
  }

  expect_failures = [var.ssh_public_key]
}
