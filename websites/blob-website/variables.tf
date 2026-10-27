variable "name" {
  description = "The name of the storage account (3-24 lowercase alphanumeric)"
  type        = string
}

variable "resource_group_name" {
  type = string
}

variable "location" {
  type = string
}

variable "account_tier" {
  type    = string
  default = "Standard"
}

variable "account_replication_type" {
  type    = string
  default = "LRS"
}

variable "index_document" {
  type    = string
  default = "index.html"
}

variable "error_document_404" {
  type    = string
  default = "404.html"
}

variable "tags" {
  type    = map(string)
  default = {}
}
