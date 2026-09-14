# 4.6 — Root-user restrictions: deny all API actions when the caller is the account's root user.
#        No exceptions baked in on purpose — genuine break-glass is handled by detaching this SCP
#        from the management account (which is never itself subject to any SCP).
resource "aws_organizations_policy" "scp_deny_root_user" {
  name        = "scp-deny-root-user"
  description = "Deny all actions when the calling principal is the account root user."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "DenyRootUser"
        Effect    = "Deny"
        Action    = "*"
        Resource  = "*"
        Condition = {
          StringLike = {
            "aws:PrincipalArn" = "arn:aws:iam::*:root"
          }
        }
      },
    ]
  })
}

resource "aws_organizations_policy_attachment" "scp_deny_root_user_sandbox" {
  policy_id = aws_organizations_policy.scp_deny_root_user.id
  target_id = aws_organizations_account.sandbox_kannan.id
}
