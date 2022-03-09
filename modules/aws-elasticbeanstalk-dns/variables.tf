##
# (c) 2021 - CloudopsWorks OÜ - https://docs.cloudops.works/
#
variable "release_name" {
  type = string
}

variable "namespace" {
  type        = string
  description = "(required) namespace that determines the environment naming"
}

variable "beanstalk_environment_cname" {
  type        = string
  description = "(required) CNAME to point records to."
}