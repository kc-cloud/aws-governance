# 4.4 — Security infrastructure protection: guard S3 buckets (by naming convention — bucket-level
#        actions like DeleteBucket don't reliably honor tag conditions), plus tagged KMS/EventBridge/SNS
#        resources (security-tier = protected), from deletion or config changes.
resource "aws_organizations_policy" "scp_security_infra_protection" {
  name        = "scp-security-infra-protection"
  description = "Protect security-logs-named S3 buckets, and tagged (security-tier=protected) KMS keys, EventBridge rules, and SNS topics, from deletion/tampering."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyProtectedS3BucketTampering"
        Effect = "Deny"
        Action = [
          "s3:DeleteBucket",
          "s3:DeleteBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:PutLifecycleConfiguration",
          "s3:PutBucketVersioning",
          "s3:PutEncryptionConfiguration",
          "s3:PutBucketAcl",
          "s3:PutBucketOwnershipControls",
        ]
        # Naming-convention-based, not tag-based: any bucket named "*-security-logs" is protected.
        Resource = "arn:aws:s3:::*-security-logs"
      },
      {
        Sid    = "DenyProtectedKmsKeyTampering"
        Effect = "Deny"
        Action = [
          "kms:ScheduleKeyDeletion",
          "kms:DisableKey",
          "kms:PutKeyPolicy",
          "kms:DeleteAlias",
          "kms:DisableKeyRotation",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/security-tier" = "protected"
          }
        }
      },
      {
        Sid    = "DenyProtectedEventBridgeRuleTampering"
        Effect = "Deny"
        Action = [
          "events:DeleteRule",
          "events:DisableRule",
          "events:RemoveTargets",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/security-tier" = "protected"
          }
        }
      },
      {
        Sid    = "DenyProtectedSnsTopicTampering"
        Effect = "Deny"
        Action = [
          "sns:DeleteTopic",
          "sns:SetTopicAttributes",
        ]
        Resource = "*"
        Condition = {
          StringEquals = {
            "aws:ResourceTag/security-tier" = "protected"
          }
        }
      },
    ]
  })
}

resource "aws_organizations_policy_attachment" "scp_security_infra_protection_sandbox" {
  policy_id = aws_organizations_policy.scp_security_infra_protection.id
  target_id = aws_organizations_account.sandbox_kannan.id
}
