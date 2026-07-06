variable "prefix" {
  description = "Prefix for resource names"
  type        = string

}
variable "location" {
  description = "Azure region for resource deployment"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {
    environment = "casopractico2"
    created_by  = "terraform"
  }
}