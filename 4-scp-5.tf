# 4.5 — Public exposure guardrails: lock S3 Block Public Access on (account + bucket level),
#        and deny setting a public canned ACL on any bucket/object.
resource "aws_organizations_policy" "scp_public_exposure_guardrails" {
  name        = "scp-public-exposure-guardrails"
  description = "Deny disabling S3 Block Public Access (account or bucket level) and deny public-read/public-read-write canned ACLs."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyS3AccountPublicAccessBlockChanges"
        Effect = "Deny"
        Action = [
          "s3:PutAccountPublicAccessBlock",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyS3BucketPublicAccessBlockChanges"
        Effect = "Deny"
        Action = [
          "s3:PutBucketPublicAccessBlock",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyPublicS3Acl"
        Effect = "Deny"
        Action = [
          "s3:PutBucketAcl",
          "s3:PutObjectAcl",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = ["public-read", "public-read-write"]
          }
        }
      },
    ]
  })
}

resource "aws_organizations_policy_attachment" "scp_public_exposure_guardrails_sandbox" {
  policy_id = aws_organizations_policy.scp_public_exposure_guardrails.id
  target_id = aws_organizations_account.sandbox_kannan.id
}
