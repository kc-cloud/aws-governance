# Lesson 3 — Member accounts (aws_organizations_account) go here.

resource "aws_organizations_account" "security_log_archive" {
  name      = "security-log-archive"
  email     = "kannan+security-log-archive@spectrasolutions.io" # unique per account — Google Workspace "+" aliasing
  parent_id = aws_organizations_organizational_unit.security.id

  # Without this, `terraform destroy` only removes the account from the Org (it becomes a
  # standalone account, still billed independently) instead of actually closing it.
  close_on_deletion = true

  lifecycle {
    ignore_changes = [role_name] # role_name only takes effect at account creation
  }
}

resource "aws_organizations_account" "infra_shared_services" {
  name      = "infra-shared-services"
  email     = "kannan+infra-shared-services@spectrasolutions.io"
  parent_id = aws_organizations_organizational_unit.infrastructure.id

  close_on_deletion = true

  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_organizations_account" "workloads_dev" {
  name      = "workloads-dev"
  email     = "kannan+workloads-dev@spectrasolutions.io"
  parent_id = aws_organizations_organizational_unit.workloads.id

  close_on_deletion = true

  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_organizations_account" "workloads_test" {
  name      = "workloads-test"
  email     = "kannan+workloads-test@spectrasolutions.io"
  parent_id = aws_organizations_organizational_unit.workloads.id

  close_on_deletion = true

  lifecycle {
    ignore_changes = [role_name]
  }
}

resource "aws_organizations_account" "workloads_prod" {
  name      = "workloads-prod"
  email     = "kannan+workloads-prod@spectrasolutions.io"
  parent_id = aws_organizations_organizational_unit.workloads.id

  close_on_deletion = true

  lifecycle {
    ignore_changes = [role_name]
  }
}
resource "aws_organizations_account" "sandbox_kannan" {
  name      = "sandbox-kannan"
  email     = "kannan+sandbox@spectrasolutions.io"
  parent_id = aws_organizations_organizational_unit.sandbox.id

  close_on_deletion = true

  lifecycle {
    ignore_changes = [role_name]
  }
}
