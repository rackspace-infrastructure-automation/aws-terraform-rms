variable "Subnets" {
  type = "list"
}

variable "AvailabilityZoneCount" {
  type = "string"
}

variable "Environment" {
  type = "string"
}

variable "build_state" {
  type    = "string"
  default = "Deploy"
}

variable "KeyName" {
  type = "string"
}

variable "InstanceRoleManagedPolicyArns" {
  type = "string"
}

variable "ThreatManagerInstanceType" {
  type = "string"
}

variable "DisableApiTermination" {
  type    = "string"
  default = "False"
}

variable "environment" {
  default = "Production"
}
