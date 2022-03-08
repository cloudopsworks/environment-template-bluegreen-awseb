variable "default_version" {
  type        = string
  description = "(Required) Version to be applied during the workspace election."
  default     = ""
}

variable "dns_weight" {
  type        = number
  description = "(Required) Weight to apply for DNS weighted distribution."
  default     = -1
}