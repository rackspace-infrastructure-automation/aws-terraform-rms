variable "alert_logic_customer_id" {
  description = "The Alert Logic Customer ID, provided by RMS. A numeric string between 3 and 12 characters in length. Omit if this is not the first RMS deployment under this account."
  type        = "string"
  default     = ""
}

variable "alert_logic_data_center" {
  description = "Alert Logic Data Center where logs will be shipped."
  type        = "string"
  default     = "US"
}

variable "az_count" {
  description = "Number of Availability Zones. For environments where only Log ingestion is required, please select 0"
  type        = "string"
  default     = 2
}

variable "build_state" {
  description = "Allowed values 'Deploy' or 'Test'.  Select 'Deploy' unless the stack is being built for testing in an account without access to the Alert Logic AMIs."
  type        = "string"
  default     = "Deploy"
}

variable "environment" {
  description = "Application environment for which this infrastructure is being created. e.g. Development/Production."
  type        = "string"
  default     = "Production"
}

variable "instance_type" {
  description = "The instance type to use for the Alert Logic appliances.  Defaults to c5.large"
  type        = "string"
  default     = "c5.large"
}

variable "key_pair" {
  description = "Name of an existing EC2 KeyPair to enable SSH access to the instances."
  type        = "string"
  default     = ""
}

variable "name" {
  description = "The name prefix to use for the resources created in this module."
  type        = "string"
}

variable "subnets" {
  description = "Private Subnet IDs for deployment. This is for the ALTM appliances."
  type        = "list"
}

variable "tags" {
  description = "Custom tags to apply to all resources."
  type        = "map"
  default     = {}
}

variable "volume_size" {
  description = "Select EBS Volume Size in GB."
  type        = "string"
  default     = "50"
}
