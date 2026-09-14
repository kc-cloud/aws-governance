# Lesson 4 — Service Control Policies (aws_organizations_policy + aws_organizations_policy_attachment) go here.

# 4.2 — IAM protection: guard sensitive roles, permission boundaries, and a common escalation path.
resource "aws_organizations_policy" "scp_iam_protection" {
  name        = "scp-iam-protection"
  description = "Protect org-managed/SSO roles from tampering, block permission-boundary removal, and block attaching AdministratorAccess."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyProtectedRoleTampering"
        Effect = "Deny"
        Action = [
          "iam:DeleteRole",
          "iam:DeleteRolePolicy",
          "iam:DetachRolePolicy",
          "iam:AttachRolePolicy",
          "iam:PutRolePolicy",
          "iam:UpdateAssumeRolePolicy",
          "iam:UpdateRole",
          "iam:UpdateRoleDescription",
          "iam:PutRolePermissionsBoundary",
          "iam:DeleteRolePermissionsBoundary",
          "iam:TagRole",
          "iam:UntagRole",
        ]
        Resource = [
          "arn:aws:iam::*:role/OrganizationAccountAccessRole",
          "arn:aws:iam::*:role/aws-reserved/sso.amazonaws.com/*",
          "arn:aws:iam::*:role/stacksets-exec-*",
          "arn:aws:iam::*:role/AWSControlTowerExecution",
        ]
      },
      {
        Sid    = "DenyPermissionBoundaryRemoval"
        Effect = "Deny"
        Action = [
          "iam:DeleteRolePermissionsBoundary",
          "iam:DeleteUserPermissionsBoundary",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyAdminPolicyAttachment"
        Effect = "Deny"
        Action = [
          "iam:AttachUserPolicy",
          "iam:AttachRolePolicy",
          "iam:AttachGroupPolicy",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PolicyARN" = "arn:aws:iam::aws:policy/AdministratorAccess"
          }
        }
      },
    ]
  })
}

resource "aws_organizations_policy_attachment" "scp_iam_protection_sandbox" {
  policy_id = aws_organizations_policy.scp_iam_protection.id
  target_id = aws_organizations_account.sandbox_kannan.id
}
