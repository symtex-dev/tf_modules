locals {
  # coalesce() selects the first non-null, non-empty name, falling back to a name
  # built from var.name. ${...} inserts a value into a string.
  environment_name = coalesce(var.environment_name, "${var.name}-env")
  app_name         = coalesce(var.container_app_name, "${var.name}-app")
  workspace_name   = coalesce(var.log_analytics_workspace_name, "${var.name}-logs")
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = local.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_days
  tags                = var.tags
}

resource "azurerm_container_app_environment" "this" {
  name                           = local.environment_name
  location                       = var.location
  resource_group_name            = var.resource_group_name
  log_analytics_workspace_id     = azurerm_log_analytics_workspace.this.id
  infrastructure_subnet_id       = var.infrastructure_subnet_id
  internal_load_balancer_enabled = var.internal_load_balancer_enabled
  tags                           = var.tags

  lifecycle {
    precondition {
      condition     = !var.internal_load_balancer_enabled || var.infrastructure_subnet_id != null
      error_message = "An internal load balancer requires infrastructure_subnet_id."
    }
  }
}

resource "azurerm_container_app" "this" {
  name                         = local.app_name
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = var.resource_group_name
  revision_mode                = var.revision_mode
  tags                         = var.tags

  dynamic "identity" {
    # One list item generates one identity block; [] omits the block entirely.
    # The number 1 is only a placeholder, not an Azure identity ID.
    for_each = var.identity_type != null ? [1] : []
    content {
      type         = var.identity_type
      identity_ids = var.identity_ids
    }
  }

  dynamic "secret" {
    # Generate a nested block per configured secret; secret.value is that item.
    for_each = var.secrets
    content {
      name  = secret.value.name
      value = secret.value.value
    }
  }

  dynamic "registry" {
    # registry.value reads the current registry object, not a module variable.
    for_each = var.registries
    content {
      server               = registry.value.server
      username             = registry.value.username
      password_secret_name = registry.value.password_secret_name
      identity             = registry.value.identity
    }
  }

  template {
    container {
      name   = var.container_name
      image  = var.container_image
      cpu    = var.cpu
      memory = var.memory

      dynamic "env" {
        for_each = var.environment_variables
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = var.secret_environment_variables
        content {
          name        = env.key
          secret_name = env.value
        }
      }
    }
  }

  dynamic "ingress" {
    # Wrap a supplied object in a one-item list to generate one ingress block.
    for_each = var.ingress == null ? [] : [var.ingress]
    content {
      external_enabled = ingress.value.external_enabled
      target_port      = ingress.value.target_port
      transport        = ingress.value.transport

      traffic_weight {
        percentage      = 100
        latest_revision = true
      }
    }
  }
}