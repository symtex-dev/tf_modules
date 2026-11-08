variable "name" {
  description = "Linux VM name; also used as the NIC name prefix."
  type        = string
}

variable "resource_group_name" {
  description = "Existing resource group for the VM, NIC, and optional public IP."
  type        = string
}

variable "location" {
  description = "Azure region for the VM and NIC; must match the subnet's VNet region."
  type        = string
}

variable "subnet_id" {
  description = "Resource ID of an existing subnet. Its VNet may be in another resource group."
  type        = string
}

variable "size" {
  description = "Azure VM size compatible with the selected image and region."
  type        = string
}

variable "admin_username" {
  description = "Linux administrator username."
  type        = string
}

variable "ssh_public_key" {
  description = "SSH public key for the administrator. Never supply a private key."
  type        = string

  validation {
    condition     = length(trimspace(var.ssh_public_key)) > 0
    error_message = "Provide a nonblank SSH public key."
  }
}

variable "source_image_id" {
  description = "Packer-created managed image or Azure Compute Gallery image version resource ID. Set exactly one image source."
  type        = string
  default     = null

  validation {
    condition     = var.source_image_id == null ? true : length(trimspace(var.source_image_id)) > 0
    error_message = "source_image_id must not be blank."
  }
}

variable "marketplace_image" {
  description = "Marketplace image reference. Set exactly one image source."
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = null

  validation {
    condition = var.marketplace_image == null ? true : alltrue([
      for value in values(var.marketplace_image) : length(trimspace(value)) > 0
    ])
    error_message = "All Marketplace image reference fields must be nonblank."
  }
}

variable "marketplace_plan" {
  description = "Purchase plan for Marketplace images or derived custom images that require one; accept the terms separately."
  type = object({
    publisher = string
    product   = string
    name      = string
  })
  default = null

  validation {
    condition = var.marketplace_plan == null ? true : alltrue([
      for value in values(var.marketplace_plan) : length(trimspace(value)) > 0
    ])
    error_message = "All Marketplace plan fields must be nonblank."
  }
}

variable "public_ip" {
  description = "Optional Standard static public IP configuration. Null means the VM has no public IP."
  type = object({
    name  = string
    zones = optional(list(string), [])
  })
  default = null

  validation {
    condition     = var.public_ip == null ? true : length(trimspace(var.public_ip.name)) > 0
    error_message = "The public IP name must not be blank."
  }
}

variable "os_disk" {
  description = "OS disk settings. Omit disk_size_gb to use the image default."
  type = object({
    caching              = optional(string, "ReadWrite")
    storage_account_type = optional(string, "Premium_LRS")
    disk_size_gb         = optional(number)
  })
  default = {}
}

variable "tags" {
  description = "Tags applied to the VM, NIC, and optional public IP."
  type        = map(string)
  default     = {}
}
