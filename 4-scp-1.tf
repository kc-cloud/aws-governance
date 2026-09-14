# Lesson 4 — Service Control Policies (aws_organizations_policy + aws_organizations_policy_attachment) go here.

# 4.1 — Prevent disabling/deleting centralized security & logging services.
resource "aws_organizations_policy" "scp_prevent_logging_tampering" {
  name        = "scp-prevent-logging-tampering"
  description = "Deny actions that disable, stop, or delete CloudTrail, Config, GuardDuty, Security Hub, Detective, Access Analyzer, and CloudWatch Logs destinations."
  type        = "SERVICE_CONTROL_POLICY"

  content = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "DenyCloudTrailTampering"
        Effect = "Deny"
        Action = [
          "cloudtrail:StopLogging",
          "cloudtrail:DeleteTrail",
          "cloudtrail:UpdateTrail",
          "cloudtrail:PutEventSelectors",
          "cloudtrail:PutInsightSelectors",
          "cloudtrail:RemoveTags",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyConfigTampering"
        Effect = "Deny"
        Action = [
          "config:StopConfigurationRecorder",
          "config:DeleteConfigurationRecorder",
          "config:DeleteDeliveryChannel",
          "config:DeleteConfigRule",
          "config:DeleteOrganizationConfigRule",
          "config:DeleteRemediationConfiguration",
          "config:DeleteRetentionConfiguration",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyGuardDutyTampering"
        Effect = "Deny"
        Action = [
          "guardduty:DeleteDetector",
          "guardduty:UpdateDetector",
          "guardduty:DisassociateFromMasterAccount",
          "guardduty:DisassociateMembers",
          "guardduty:DeleteMembers",
          "guardduty:DeleteInvitations",
          "guardduty:DeleteFilter",
          "guardduty:DeleteIPSet",
          "guardduty:DeleteThreatIntelSet",
          "guardduty:DisableOrganizationAdminAccount",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenySecurityHubTampering"
        Effect = "Deny"
        Action = [
          "securityhub:DeleteHub",
          "securityhub:DisableSecurityHub",
          "securityhub:DisassociateFromMasterAccount",
          "securityhub:DisassociateMembers",
          "securityhub:DeleteMembers",
          "securityhub:BatchDisableStandards",
          "securityhub:UpdateStandardsControl",
          "securityhub:DisableOrganizationAdminAccount",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyDetectiveTampering"
        Effect = "Deny"
        Action = [
          "detective:DeleteGraph",
          "detective:DisassociateMembership",
          "detective:DeleteMembers",
          "detective:DisableOrganizationAdminAccount",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyAccessAnalyzerTampering"
        Effect = "Deny"
        Action = [
          "access-analyzer:DeleteAnalyzer",
        ]
        Resource = "*"
      },
      {
        Sid    = "DenyLogDestinationTampering"
        Effect = "Deny"
        Action = [
          "logs:DeleteLogGroup",
          "logs:DeleteLogStream",
          "logs:DeleteSubscriptionFilter",
          "logs:DeleteDestination",
          "logs:PutRetentionPolicy",
        ]
        Resource = "*"
      },
    ]
  })
}

# Attach to the low-stakes sandbox account first, per our test-before-rollout plan.
resource "aws_organizations_policy_attachment" "scp_prevent_logging_tampering_sandbox" {
  policy_id = aws_organizations_policy.scp_prevent_logging_tampering.id
  target_id = aws_organizations_account.sandbox_kannan.id
}
