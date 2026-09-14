provider "aws" {
  region  = var.region
  profile = var.profile
}

# Assumes into the sandbox account so we can manage IAM resources (like permission boundaries)
# that live inside it, rather than in the management account.
provider "aws" {
  alias   = "sandbox"
  region  = var.region
  profile = var.profile

  assume_role {
    role_arn     = "arn:aws:iam::${var.sandbox_account_id}:role/OrganizationAccountAccessRole"
    session_name = "terraform-sandbox"
  }
}
