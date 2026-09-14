# 4.3 — Organizations/governance protection: prevent leaving the org and tampering with its structure.
resource "aws_organizations_policy" "scp_org_governance_protection" {
  name        = "scp-org-governance-protection"
  description = "Deny leaving/closing the account and deny unauthorized changes to Organizations structure (OUs, policies, delegated admins)."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyLeavingOrganization"
        Effect = "Deny"
        Action = [
          "organizations:LeaveOrganization",
          "organizations:CloseAccount",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyOrganizationsGovernanceTampering"
        Effect = "Deny"
        Action = [
          "organizations:CreateOrganization",
          "organizations:DeleteOrganization",
          "organizations:DisablePolicyType",
          "organizations:EnablePolicyType",
          "organizations:EnableAllFeatures",
          "organizations:CreateOrganizationalUnit",
          "organizations:UpdateOrganizationalUnit",
          "organizations:DeleteOrganizationalUnit",
          "organizations:MoveAccount",
          "organizations:RemoveAccountFromOrganization",
          "organizations:CreatePolicy",
          "organizations:UpdatePolicy",
          "organizations:DeletePolicy",
          "organizations:AttachPolicy",
          "organizations:DetachPolicy",
          "organizations:RegisterDelegatedAdministrator",
          "organizations:DeregisterDelegatedAdministrator",
        ]
        Resource = "*"
      },
    ]
  })
}

resource "aws_organizations_policy_attachment" "scp_org_governance_protection_sandbox" {
  policy_id = aws_organizations_policy.scp_org_governance_protection.id
  target_id = aws_organizations_account.sandbox_kannan.id
}
