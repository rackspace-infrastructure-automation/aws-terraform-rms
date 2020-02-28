variable "assume_role_policy" {
  description = "A json string containing the assume role policy to use for the IAM role."
  type        = "string"
}

variable "build_state" {
  description = "A variable to control whether resources should be built"
  type        = "string"
  default     = true
}

variable "name" {
  description = "The name prefix for these IAM resources"
  type        = "string"
}

variable "policy_arns" {
  description = "A list of managed IAM policies to attach to the IAM role"
  type        = "list"
  default     = []
}

variable "policy_file" {
  description = "A string containing the file path to the IAM policy to attach to the role"
  type        = "string"
}

variable "policy_vars" {
  description = "A map of keys and values.  The keys referenced in the policy_file will be replaced by the appropriate value.  See https://www.terraform.io/docs/providers/template/d/file.html for further details."
  type        = "map"
  default     = {}
}
