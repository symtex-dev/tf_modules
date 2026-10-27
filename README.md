# Azure Terraform modules

Reusable Azure Terraform modules are grouped by purpose:

- [`core/`](./core/) contains shared infrastructure modules, including
  network composition, governance, and resource modules.
- [`booking-engine/`](./booking-engine/) contains workload-specific modules.
- [`websites/`](./websites/) contains website, DNS, and Front Door modules.

For a GitHub module source, select the module's subdirectory:

```hcl
module "vnet" {
  source = "git::https://github.com/<ORG>/<REPO>.git//core/vnet"
}
```

Terraform downloads the repository package when using a subdirectory source;
this lets composed modules use sibling modules via relative paths. Configure
Terraform and provider versions in the calling root configuration.

## Core building blocks

Existing modules cover resource groups, management groups, policy, subscription
association, Key Vault, container registry, public DNS/domains, and hub/spoke
networking (VNets, subnets, NSGs, rules, routes, peering, and VPN).

Additional shared modules:

| Module | Purpose |
| --- | --- |
| [foundation](./core/foundation/) | Composes a resource group, managed identity, monitoring, optional storage and RBAC, and optional blob private connectivity using sibling modules |
| [managed-identity](./core/managed-identity/) | User-assigned identity for workload authentication |
| [role-assignment](./core/role-assignment/) | RBAC assignments by role name or role definition ID |
| [storage-account](./core/storage-account/) | Standard StorageV2 with HTTPS, TLS 1.2, and private/Entra-first defaults |
| [monitoring](./core/monitoring/) | Log Analytics and workspace-backed Application Insights |
| [private-dns-zone](./core/private-dns-zone/) | Private DNS zone and named VNet links |
| [private-endpoint](./core/private-endpoint/) | Private Link connection and optional existing DNS zone association |

New modules require Terraform >= 1.6 and AzureRM 4.x. Mock-provider tests require
Terraform >= 1.7. Existing workload modules remain unchanged.

## Local files and cleanup

Generated Terraform/Terragrunt caches, state, saved plans, local variable files,
environment secrets, and editor leftovers are ignored. Sanitized
`*.example.tfvars`, `*.example.tfvars.json`, and `.env.example` files may be
versioned; never put real credentials in them. Root provider lockfiles may be
committed for a root configuration; nested reusable-module lockfiles are ignored.
State and secrets must be backed up or explicitly approved before deletion:
ignore rules are not a cleanup command or a backup.

## Verify the new modules

```sh
terraform -chdir=core/foundation init -backend=false
terraform -chdir=core/foundation validate
terraform -chdir=core/foundation test
```

Tests use a mocked AzureRM provider and do not deploy Azure resources or require
Azure credentials. Initialization downloads the provider plugin.
