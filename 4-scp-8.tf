# 4.8 — Data-perimeter baseline: deny access to resources whose owning AWS Organization
#        doesn't match ours, so credentials can't be used to reach data outside the org.
#        Simplified teaching version of AWS's published "data perimeter" pattern — a real
#        production policy has a longer, carefully-tuned NotAction exception list.
resource "aws_organizations_policy" "scp_data_perimeter_baseline" {
  name        = "scp-data-perimeter-baseline"
  description = "Deny access to resources outside the organization (aws:ResourceOrgID mismatch), exempting AWS service principals and a few inherently org-agnostic actions."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "EnforceResourcePerimeter"
        Effect = "Deny"
        NotAction = [
          "iam:*",
          "sts:*",
          "organizations:*",
          "s3:ListAllMyBuckets",
          "s3:GetAccountPublic*",
          "s3:PutAccountPublic*",
          "ec2:Describe*",
          "tag:GetResources",
          "tag:GetTagKeys",
          "tag:GetTagValues",
          "support:*",
          "trustedadvisor:*",
          "health:*",
          "budgets:*",
          "ce:*",
          "cur:*",
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            # Escaped as $$ so Terraform emits a literal IAM policy variable, not its own interpolation.
            "aws:ResourceOrgID" = "$${aws:PrincipalOrgID}"
          }
          Null = {
            "aws:ResourceOrgID" = "false" # only apply when the resource actually reports an org ID
          }
          BoolIfExists = {
            "aws:PrincipalIsAWSService" = "false" # don't block AWS services acting on your behalf
          }
        }
      },
    ]
  })
}

resource "aws_organizations_policy_attachment" "scp_data_perimeter_baseline_sandbox" {
  policy_id = aws_organizations_policy.scp_data_perimeter_baseline.id
  target_id = aws_organizations_account.sandbox_kannan.id
}
