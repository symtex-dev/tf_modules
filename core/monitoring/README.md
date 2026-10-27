# Monitoring

Creates a PerGB2018 Log Analytics workspace and workspace-backed Application
Insights in an existing resource group. This shared building block is independent
of the existing website-specific observability module.
Requires Terraform >= 1.6 and AzureRM 4.x; configure the provider in the caller.

```hcl
module "monitoring" {
  source = "git::https://github.com/<ORG>/<REPO>.git//core/monitoring"

  workspace_name            = "platform-logs"
  application_insights_name = "platform-insights"
  resource_group_name       = "platform-rg"
  location                  = "westeurope"
  retention_in_days         = 30
}
```

Required inputs: `workspace_name`, `application_insights_name`,
`resource_group_name`, `location`. `retention_in_days` defaults to 30 and accepts
whole numbers from 30 to 730. `application_type` defaults to `web` and also accepts
`other`, `java`, and `MobileCenter`. `tags` defaults to `{}`.

Outputs: `workspace_id`, `application_insights_id`, and sensitive `connection_string`.
Configure your application's telemetry SDK separately with that connection string.
Diagnostic settings for other Azure resources and alert rules are not created.
Ingestion and retention may incur charges.
