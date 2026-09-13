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
