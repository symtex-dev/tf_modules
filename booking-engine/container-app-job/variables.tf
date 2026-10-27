variable "name" {
  description = "Name of the Container Apps Job."
  type        = string
}

variable "resource_group_name" {
  description = "Resource group containing the Container Apps environment."
  type        = string
}

variable "location" {
  description = "Azure location for the job."
  type        = string
}

variable "container_app_environment_id" {
  description = "ID of the existing Container Apps environment where the job runs."
  type        = string
}

variable "container_image" {
  description = "Image to run for the migration job."
  type        = string
}

variable "container_name" {
  description = "Name of the job container."
  type        = string
  default     = "migration"
}

variable "command" {
  description = "Container command that overrides the image command."
  type        = list(string)
  default     = ["npm"]
}

variable "args" {
  description = "Arguments passed to the container command."
  type        = list(string)
  default     = ["run", "migrate", "--", "up"]
}

variable "environment_variables" {
  description = "Non-secret environment variables passed to the migration process."
  type        = map(string)
  default     = {}
}

variable "secret_environment_variables" {
  description = "Environment variable names mapped to Container Apps secret names."
  type        = map(string)
  default     = {}
}

variable "postgres_password" {
  description = "Password used by the migration process to connect to PostgreSQL."
  type        = string
  sensitive   = true
}

variable "acr_server" {
  description = "Container registry server hostname."
  type        = string
  default     = "smtxacr.azurecr.io"
}

variable "acr_username" {
  description = "Container registry username."
  type        = string
}

variable "acr_password" {
  description = "Container registry password."
  type        = string
  sensitive   = true
}

variable "cpu" {
  description = "CPU allocated to the job container."
  type        = number
  default     = 0.25
}

variable "memory" {
  description = "Memory allocated to the job container."
  type        = string
  default     = "0.5Gi"
}

variable "replica_timeout_in_seconds" {
  description = "Maximum run time for one migration job execution."
  type        = number
  default     = 1800
}

variable "tags" {
  description = "Tags applied to the Container Apps Job."
  type        = map(string)
  default     = {}
}