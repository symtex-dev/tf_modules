# Azure Static Web App Module

Creates an Azure Static Web App and optionally connects a subdomain using an
existing Azure DNS zone. Azure automatically provisions the custom domain's HTTPS
certificate after domain validation.

## Usage

```hcl
provider "azurerm" {
  features {}
}

module "static_website" {
  source = "./module/static-website"

  prefix              = "dev"
  resource_group_name = "website-rg"
  location            = "West Europe"
  sku_size            = "Free"

  custom_domain = {
    subdomain           = "dev"
    zone_name           = "domain.com"
    resource_group_name = "dns-rg"
  }

  tags = {
    environment = "dev"
  }
}
```

This creates a `dev` CNAME in the existing `domain.com` zone, pointing to the app's
generated hostname, and registers `dev.domain.com` with the app. Terraform creates
the CNAME before registering the domain; DNS propagation and certificate issuance
may take time.

The DNS zone must already exist, and the domain registrar must delegate the domain
to its Azure DNS nameservers. The Terraform identity needs permission to manage
records in the DNS zone, which can be in a different resource group from the app
but uses the same AzureRM provider configuration. An existing CNAME at the same
name must be imported into Terraform before applying; conflicting records must
be resolved first.

Omit `custom_domain` (or set it to `null`) to create only the app, preserving the
module's original behavior. `prefix` controls the Azure resource name, not the
DNS subdomain. This configuration supports a single subdomain label such as `dev`
or `www`, not the apex domain (`domain.com`).

## Inputs

| Name | Description | Default |
| --- | --- | --- |
| `prefix` | Prefix used in the app name `smtx-<prefix>`. | Required |
| `resource_group_name` | Existing resource group for the app. | Required |
| `location` | Azure region for the app. | Required |
| `sku_size` | Static Web App SKU size. | Required |
| `tags` | Tags applied to the app and CNAME record. | `{}` |
| `custom_domain` | Object with `subdomain`, `zone_name`, and the DNS zone's `resource_group_name`. | `null` |

The CNAME record uses a TTL of 300 seconds and CNAME delegation validation.

## Terragrunt with the DNS zone module

Use separate sibling Terragrunt units for the zone and website:

```text
live/
  root.hcl
  dns_zone/
    terragrunt.hcl
  static-website/
    terragrunt.hcl
```

The shared `root.hcl` should configure your AzureRM provider and your normal
per-unit remote state backend. Both units must use the same Azure subscription
for this example. The resource groups must already exist.

In `live/dns_zone/terragrunt.hcl`:

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::https://github.com/<ORG>/<REPO>.git//websites/dns_zone"
}

inputs = {
  dns_zone_name       = "domain.com"
  resource_group_name = "dns-rg"
}
```

In `live/static-website/terragrunt.hcl`:

```hcl
include "root" {
  path = find_in_parent_folders("root.hcl")
}

terraform {
  source = "git::https://github.com/<ORG>/<REPO>.git//websites/static-website"
}

dependency "dns_zone" {
  config_path = "../dns_zone"
}

inputs = {
  prefix              = "dev"
  resource_group_name = "website-rg"
  location            = "West Europe"
  sku_size            = "Free"

  custom_domain = {
    subdomain           = "dev"
    zone_name           = dependency.dns_zone.outputs.dns_zone_name
    resource_group_name = dependency.dns_zone.outputs.resource_group_name
  }
}
```

Publish these module changes before using the Git sources above; pin both sources
to a published tag or commit with `?ref=<ref>` for reproducible deployments.

The `dependency` block reads the DNS unit's Terraform outputs and orders the DNS
unit before the website when running `terragrunt run --all apply` from `live/`.
The DNS unit owns the zone (and its optional TXT/MX records); the website unit owns
only its CNAME and custom-domain registration. Do not manage the same DNS record
in both units.

For a new domain, first run `terragrunt apply` in `live/dns_zone/`, then
`terragrunt output name_servers`. Configure those nameservers at your registrar
and wait for delegation to propagate before applying the website unit. Terragrunt
dependency ordering cannot perform registrar delegation for you.

If the DNS unit was already deployed before the new outputs were added, apply it
again to persist `resource_group_name` and `name_servers` in state before planning
the website. The dependency intentionally uses real outputs, not mock values
during apply.

## Outputs

- `id`: Static Web App resource ID.
- `name`: Static Web App resource name.
- `location`: Static Web App location.
- `default_host_name`: Generated hostname (without `https://`).
- `custom_domain_name`: Registered custom domain, or `null` when disabled.

## Tests

With Terraform 1.7 or later, run `terraform init -backend=false`, followed by
`terraform test` from this module's directory. Tests use a mocked AzureRM provider
and do not create Azure resources.
The suite also applies the DNS zone module with the mocked provider and passes
its outputs into the website module, exercising the same output/input contract
used by the Terragrunt dependency.
