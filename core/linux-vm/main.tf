resource "azurerm_public_ip" "this" {
  for_each = var.public_ip == null ? {} : { main = var.public_ip }

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
  zones               = each.value.zones
  tags                = var.tags
}

resource "azurerm_network_interface" "this" {
  name                = "${var.name}-nic"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip == null ? null : azurerm_public_ip.this["main"].id
  }
}

resource "azurerm_linux_virtual_machine" "this" {
  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.size
  admin_username                  = var.admin_username
  disable_password_authentication = true
  network_interface_ids           = [azurerm_network_interface.this.id]
  source_image_id                 = var.source_image_id
  tags                            = var.tags

  custom_data = var.custom_data

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  os_disk {
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
    disk_size_gb         = var.os_disk.disk_size_gb
  }

  dynamic "source_image_reference" {
    for_each = var.marketplace_image == null ? [] : [var.marketplace_image]

    content {
      publisher = source_image_reference.value.publisher
      offer     = source_image_reference.value.offer
      sku       = source_image_reference.value.sku
      version   = source_image_reference.value.version
    }
  }

  dynamic "plan" {
    for_each = var.marketplace_plan == null ? [] : [var.marketplace_plan]

    content {
      publisher = plan.value.publisher
      product   = plan.value.product
      name      = plan.value.name
    }
  }

  lifecycle {
    precondition {
      condition     = (var.source_image_id != null) != (var.marketplace_image != null)
      error_message = "Set exactly one of source_image_id and marketplace_image."
    }
  }
}
