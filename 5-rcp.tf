# Lesson 5 — Resource Control Policies (aws_organizations_policy + aws_organizations_policy_attachment) go here.

# 5.1 — Enforce identity perimeter from the resource side: deny access to supported resource
#        types (S3, KMS, SQS, Secrets Manager, STS) unless the caller belongs to this same
#        organization — regardless of what any resource-based policy (e.g. an S3 bucket policy)
#        says. This is the resource-side mirror of the SCP #8 data-perimeter policy.
resource "aws_organizations_policy" "rcp_enforce_identity_perimeter" {
  name        = "rcp-enforce-identity-perimeter"
  description = "Deny access to supported resource types unless the calling principal belongs to this organization."
  type        = "RESOURCE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforceIdentityPerimeter"
        Effect = "Deny"
        Principal = "*"
        # RCPs reject a bare "*" here — must be scoped to specific service prefixes.
        Action   = ["s3:*", "kms:*", "sqs:*", "secretsmanager:*", "sts:*"]
        Resource = "*"
        Condition = {
          StringNotEqualsIfExists = {
            # Escaped as $$ so Terraform emits a literal IAM policy variable, not its own interpolation.
            "aws:PrincipalOrgID" = "$${aws:ResourceOrgID}"
          }
          BoolIfExists = {
            "aws:PrincipalIsAWSService" = "false"
          }
        }
      },
    ]
  })
}

resource "aws_organizations_policy_attachment" "rcp_enforce_identity_perimeter_sandbox" {
  policy_id = aws_organizations_policy.rcp_enforce_identity_perimeter.id
  target_id = aws_organizations_account.sandbox_kannan.id
}

# 5.2 — Enforce TLS-only access: deny any request to a supported resource type that wasn't
#        made over a secure (HTTPS/TLS) connection.
resource "aws_organizations_policy" "rcp_enforce_secure_transport" {
  name        = "rcp-enforce-secure-transport"
  description = "Deny access to supported resource types when the request isn't made over TLS."
  type        = "RESOURCE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "EnforceSecureTransport"
        Effect    = "Deny"
        Principal = "*"
        # RCPs reject a bare "*" here — must be scoped to specific service prefixes.
        Action   = ["s3:*", "kms:*", "sqs:*", "secretsmanager:*", "sts:*"]
        Resource = "*"
        Condition = {
          BoolIfExists = {
            "aws:SecureTransport" = "false"
          }
        }
      },
    ]
  })
}

resource "aws_organizations_policy_attachment" "rcp_enforce_secure_transport_sandbox" {
  policy_id = aws_organizations_policy.rcp_enforce_secure_transport.id
  target_id = aws_organizations_account.sandbox_kannan.id
}
