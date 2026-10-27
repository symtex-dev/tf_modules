variable "management_groups" {
  description = "Management groups to create."

  type = map(object({
    display_name = string
    parent_id    = optional(string)
  }))
}