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

output "scp_prevent_logging_tampering_id" {
  value = aws_organizations_policy.scp_prevent_logging_tampering.id
}

output "scp_iam_protection_id" {
  value = aws_organizations_policy.scp_iam_protection.id
}

output "scp_org_governance_protection_id" {
  value = aws_organizations_policy.scp_org_governance_protection.id
}

output "scp_security_infra_protection_id" {
  value = aws_organizations_policy.scp_security_infra_protection.id
}

output "scp_public_exposure_guardrails_id" {
  value = aws_organizations_policy.scp_public_exposure_guardrails.id
}

output "scp_deny_root_user_id" {
  value = aws_organizations_policy.scp_deny_root_user.id
}

output "scp_region_restriction_id" {
  value = aws_organizations_policy.scp_region_restriction.id
}

output "scp_data_perimeter_baseline_id" {
  value = aws_organizations_policy.scp_data_perimeter_baseline.id
}

output "rcp_enforce_identity_perimeter_id" {
  value = aws_organizations_policy.rcp_enforce_identity_perimeter.id
}

output "rcp_enforce_secure_transport_id" {
  value = aws_organizations_policy.rcp_enforce_secure_transport.id
}

output "developer_permission_boundary_arn" {
  value = aws_iam_policy.developer_permission_boundary.arn
}

output "boundary_demo_role_arn" {
  value = aws_iam_role.boundary_demo.arn
}
