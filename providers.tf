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

locals {
  # Must stay one of the SCP #7 allowed regions (us-east-2/us-west-2) — EC2/VPC actions
  # aren't exempted from that region restriction the way IAM is.
  network_region = "us-east-2"
}

# Same sandbox account, but pinned to an SCP #7-allowed region for VPC/networking resources.
provider "aws" {
  alias   = "sandbox_network"
  region  = local.network_region
  profile = var.profile

  assume_role {
    role_arn     = "arn:aws:iam::${var.sandbox_account_id}:role/OrganizationAccountAccessRole"
    session_name = "terraform-sandbox-network"
  }
}
