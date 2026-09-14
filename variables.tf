variable "region" {
  description = "AWS region for the provider (AWS Organizations itself is global, but the provider still needs a region)."
  type        = string
  default     = "us-east-1"
}

variable "profile" {
  description = "Optional named AWS CLI profile to use for the management/payer account. Leave null to use default credential resolution."
  type        = string
  default     = null
}

variable "sandbox_account_id" {
  description = "Account ID of the sandbox-kannan member account. Kept as a plain value (not a resource reference) so the aws.sandbox provider alias doesn't depend on a managed resource."
  type        = string
  default     = "189575358180"
}
