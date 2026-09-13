# Lesson 1 — AWS Organization (aws_organizations_organization) goes here.

resource "aws_organizations_organization" "this" {
  feature_set = "ALL" # required for SCPs/RCPs later; "CONSOLIDATED_BILLING" only gives billing consolidation
}
