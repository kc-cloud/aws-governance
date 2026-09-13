# Outputs get added alongside each lesson's resources as they're introduced.

output "organization_id" {
  value = aws_organizations_organization.this.id
}

output "organization_arn" {
  value = aws_organizations_organization.this.arn
}

output "management_account_id" {
  value = aws_organizations_organization.this.master_account_id
}

output "root_id" {
  description = "ID of the org's root OU — this is the parent_id you'll use for top-level OUs in the next lesson."
  value       = aws_organizations_organization.this.roots[0].id
}

output "security_ou_id" {
  value = aws_organizations_organizational_unit.security.id
}

output "infrastructure_ou_id" {
  value = aws_organizations_organizational_unit.infrastructure.id
}

output "workloads_ou_id" {
  value = aws_organizations_organizational_unit.workloads.id
}

output "sandbox_ou_id" {
  value = aws_organizations_organizational_unit.sandbox.id
}

output "security_log_archive_account_id" {
  value = aws_organizations_account.security_log_archive.id
}

output "infra_shared_services_account_id" {
  value = aws_organizations_account.infra_shared_services.id
}

output "workloads_dev_account_id" {
  value = aws_organizations_account.workloads_dev.id
}

output "workloads_test_account_id" {
  value = aws_organizations_account.workloads_test.id
}

output "workloads_prod_account_id" {
  value = aws_organizations_account.workloads_prod.id
}

output "sandbox_kannan_account_id" {
  value = aws_organizations_account.sandbox_kannan.id
}
