# Lesson 6 — IAM permission boundaries. Created directly in the sandbox account (via the
# aws.sandbox provider alias), since these are account-local IAM resources, not
# Organizations-level resources like SCPs/RCPs.

# 6.1 — The boundary itself: caps maximum permissions to a small set of "developer" services,
#        and explicitly blocks the classic boundary-escalation vectors (creating new
#        identities/policies, or tampering with permission boundaries themselves).
resource "aws_iam_policy" "developer_permission_boundary" {
  provider    = aws.sandbox
  name        = "developer-permission-boundary"
  description = "Maximum permissions for developer roles: common dev services only, no IAM escalation."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCommonDeveloperServices"
        Effect = "Allow"
        Action = [
          "s3:*",
          "dynamodb:*",
          "logs:*",
          "cloudwatch:*",
          "ec2:Describe*",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyIamEscalation"
        Effect = "Deny"
        Action = [
          "iam:CreateUser",
          "iam:CreatePolicy",
          "iam:CreatePolicyVersion",
          "iam:CreateRole",
          "iam:AttachUserPolicy",
          "iam:AttachRolePolicy",
          "iam:PutUserPolicy",
          "iam:PutRolePolicy",
          "iam:PutRolePermissionsBoundary",
          "iam:PutUserPermissionsBoundary",
          "iam:DeleteRolePermissionsBoundary",
          "iam:DeleteUserPermissionsBoundary",
        ]
        Resource = "*"
      },
    ]
  })
}

# 6.2 — A demo role with the boundary attached, plus an identity-based policy that's
#        intentionally BROADER than the boundary (ec2:*/rds:*, not just ec2:Describe*).
#        This proves the point of a boundary: effective permissions = intersection of the
#        identity policy and the boundary, so ec2:Describe* works but ec2:RunInstances and
#        anything rds:* does not, even though the identity policy alone would allow it.
#        (Deliberately not using the AdministratorAccess managed policy here — SCP #2's
#        DenyAdminPolicyAttachment statement would block attaching that specific policy ARN.)
resource "aws_iam_role" "boundary_demo" {
  provider = aws.sandbox
  name     = "boundary-demo-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = { AWS = "arn:aws:iam::${var.sandbox_account_id}:root" }
        Action    = "sts:AssumeRole"
      },
    ]
  })

  permissions_boundary = aws_iam_policy.developer_permission_boundary.arn
}

resource "aws_iam_policy" "boundary_demo_broad_policy" {
  provider    = aws.sandbox
  name        = "boundary-demo-broad-policy"
  description = "Intentionally broader than the developer boundary, to demonstrate the boundary capping effective permissions."

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:*", "rds:*", "s3:*", "dynamodb:*"]
        Resource = "*"
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "boundary_demo_broad" {
  provider   = aws.sandbox
  role       = aws_iam_role.boundary_demo.name
  policy_arn = aws_iam_policy.boundary_demo_broad_policy.arn
}
