# ----------------------------------------
#    Root module Input variables
# ----------------------------------------

variable "region_target" {
  description = "The host AWS region for services usage"
  type        = string
}

variable "resource_tags" {
  description = "Baseline tags to identify resources"
  type        = map(string)
}

variable "ssh_keys_path" {
  description = "SSH keys path"
  type        = string
}

variable "mysql_configuration" {
  description = "Base Mysql configuration"
  type        = map(string)
}

variable "couchbase_configuration" {
  description = "Map all configurations of a couchbase cluster"
  type = map(string)
}