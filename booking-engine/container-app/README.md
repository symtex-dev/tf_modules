# Container App module

Creates a Log Analytics workspace, Container Apps environment, and one Container
App running the supplied image. It does not build that image or create its
container registry. Supply `name`, `resource_group_name`, `location`, and
`container_image`; CPU, memory, revision mode, and names can be overridden.

`coalesce` in `main.tf` chooses an explicit resource name or a fallback based on
`name`. Dynamic blocks emit identity, secret, registry, and ingress settings
only when requested. The optional identity uses `[1]` as a one-item list; the
number itself has no meaning. Ingress uses `[var.ingress]` to wrap the supplied
object. With null ingress, no ingress block is emitted. Enabled ingress routes
100 percent of its traffic to the latest revision.

Registry settings refer to configured secret names or managed identities.
Secret values remain sensitive information and can be stored in Terraform
state. Database environment variables still need to be supplied by the caller.
Deploying it alone does not configure database authentication or private DNS.

## Networking

Set `infrastructure_subnet_id` to an existing dedicated subnet's Azure resource
ID to connect the environment to a VNet. Leave it null to retain Azure-managed
networking. This module uses a Consumption-only environment, which requires a
subnet of `/23` or larger, separate from the PostgreSQL private endpoint subnet.
For example, the container Terragrunt unit can declare a spoke dependency and
pass its subnet output:

```hcl
dependency "spoke" {
	config_path = "../core/spoke"
}

inputs = {
	# Include the other required module inputs here as well.
	infrastructure_subnet_id = dependency.spoke.outputs.subnet_ids["container-apps-subnet"]
}
```

Keep `internal_load_balancer_enabled = false` when browsers must reach the API
over public HTTPS. VNet integration still allows outbound private database
access. Set it to true only when environment ingress should be private; this
requires a subnet and a private access/DNS design for clients. App-level
`ingress` remains a separate setting.

Changing the subnet or internal load balancer setting replaces the environment
and can replace its app. Review the plan for downtime and changed hostnames;
no networking change is applied merely by adding these module inputs.

Outputs include the app ID/name, latest revision FQDN, environment ID, and
workspace ID. An output hostname is not proof that the app is healthy or that
external ingress is enabled.