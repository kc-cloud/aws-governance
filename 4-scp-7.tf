# 4.7 — Region restriction: deny everything outside us-east-2 / us-west-2, except actions
#        belonging to inherently global services (these have no meaningful "region").
resource "aws_organizations_policy" "scp_region_restriction" {
  name        = "scp-region-restriction"
  description = "Deny all actions outside us-east-2/us-west-2, except for global services (IAM, Organizations, Route 53, CloudFront, Support, etc.)."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyAllOutsideAllowedRegions"
        Effect = "Deny"
        NotAction = [
          "a4b:*",
          "acm:*",
          "aws-marketplace-management:*",
          "aws-marketplace:*",
          "aws-portal:*",
          "budgets:*",
          "ce:*",
          "chime:*",
          "cloudfront:*",
          "config:*",
          "cur:*",
          "directconnect:*",
          "ec2:DescribeRegions",
          "ec2:DescribeTransitGateways",
          "ec2:DescribeVpnGateways",
          "fms:*",
          "globalaccelerator:*",
          "health:*",
          "iam:*",
          "importexport:*",
          "kms:*",
          "mobileanalytics:*",
          "networkmanager:*",
          "organizations:*",
          "pricing:*",
          "route53:*",
          "route53domains:*",
          "route53-recovery-cluster:*",
          "route53-recovery-control-config:*",
          "route53-recovery-readiness:*",
          "s3:GetAccountPublic*",
          "s3:ListAllMyBuckets",
          "s3:PutAccountPublic*",
          "shield:*",
          "sts:*",
          "support:*",
          "trustedadvisor:*",
          "waf-regional:*",
          "waf:*",
          "wafv2:*",
          "wellarchitected:*",
        ]
        Resource = "*"
        Condition = {
          StringNotEquals = {
            "aws:RequestedRegion" = ["us-east-2", "us-west-2"]
          }
        }
      },
    ]
  })
}

resource "aws_organizations_policy_attachment" "scp_region_restriction_sandbox" {
  policy_id = aws_organizations_policy.scp_region_restriction.id
  target_id = aws_organizations_account.sandbox_kannan.id
}
