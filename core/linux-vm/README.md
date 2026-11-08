# Linux virtual machine

Creates a Linux VM and network interface in an **existing resource group**,
connected to an **existing subnet**. Provide the subnet resource ID directly;
the subnet's VNet may be in a different resource group. The VM, NIC, and VNet
must be in the same Azure region. The caller must have permission to create
resources in the VM resource group and join the subnet.

The VM uses SSH public-key authentication and disables password login. It has a
private IP and no public IP by default. It does not create the resource group,
VNet, subnet, NSG, VPN, SSH key, or install software.

## Packer image and private access

```hcl
module "proxy_vm" {
  source = "git::https://github.com/<ORG>/<REPO>.git//core/linux-vm"

  name                = "proxy-vm"
  resource_group_name = "workload-rg"
  location            = "westeurope"
  subnet_id           = module.hub.subnet_ids["workloads"]
  size                = "Standard_B2s"
  admin_username      = "azureadmin"
  ssh_public_key      = var.ssh_public_key
  source_image_id     = var.packer_image_id
  tags                = { environment = "production" }
}
```

`source_image_id` accepts an Azure managed image ID or an Azure Compute Gallery
image **version** ID, such as a Packer-built image. The image must be compatible
with Azure Linux VMs, the chosen VM size, and the target region; gallery images
must be replicated to that region. Image-specific OS provisioning requirements
still apply.

To use a Marketplace image instead, omit `source_image_id` and set
`marketplace_image`:

```hcl
marketplace_image = {
  publisher = "Canonical"
  offer     = "0001-com-ubuntu-server-jammy"
  sku       = "22_04-lts-gen2"
  version   = "latest"
}
```

Exactly one image source is required. Use a specific Marketplace version rather
than `latest` for reproducible deployments. Some Marketplace images require a
`marketplace_plan` object (`publisher`, `product`, `name`) and separately
accepted Marketplace terms. Packer images derived from Marketplace images may
also require the original purchase plan and accepted terms.

## Optional public IP

Set `public_ip = { name = "proxy-vm-pip" }` to create and attach a Standard,
static public IP. `zones` may be specified when supported in the region. A
public IP does not create NSG rules: explicitly restrict any inbound rules to
trusted sources. Prefer private connectivity through the P2S VPN for SSH and
SOCKS5; do not expose the proxy publicly. The existing subnet's NSG and routing
continue to apply. The private IP is dynamically allocated and can change;
check `private_ip_address` before configuring the proxy client. Internet egress,
including Azure's outbound access requirements, must be configured separately.

## Inputs and outputs

Required inputs: `name`, `resource_group_name`, `location`, `subnet_id`, `size`,
`admin_username`, `ssh_public_key`, and exactly one of `source_image_id` or
`marketplace_image`. Optional inputs: `marketplace_plan`, `public_ip`, `os_disk`
(defaults to Premium_LRS with ReadWrite caching), and `tags`. The VM size must
support the chosen disk type. Tags apply to the VM, NIC, and optional public IP.

Outputs: `id`, `name`, `network_interface_id`, `private_ip_address`, and
`public_ip_address` (null when disabled).

## Verify

```sh
terraform init -backend=false
terraform validate
terraform test
```

Tests use a mocked AzureRM provider and require Terraform >= 1.7. They do not
deploy Azure resources or verify real connectivity.
