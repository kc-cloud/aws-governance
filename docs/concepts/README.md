# Advanced Concepts — AWS Governance / Policy Engineering

These seven docs cover governance concepts that go beyond what the hands-on lessons in this repo directly built — things like policy inheritance, rollout methodology, and adjacent tooling. Each doc explains the concept, ties it back to something concrete from the `1-*.tf` through `7-*.tf` lessons where possible, and ends with a few Q&A-style checks for understanding.

1. [Policy Inheritance Across the OU Hierarchy](1-policy-inheritance.md) — how SCPs/RCPs stack from root → OU → account (with diagrams)
2. [Control Tower Default Guardrails & Overlap Analysis](2-control-tower-guardrails.md) — what Control Tower gives you for free, and how to avoid duplicating it
3. [Blast Radius Analysis & Phased Rollout](3-blast-radius-analysis.md) — formalizing the "test on sandbox first" pattern this repo actually used
4. [Policy Testing & Validation Tooling](4-policy-testing-tooling.md) — what the Policy Simulator, Access Analyzer, and linters actually do (and don't)
5. [OPA and Cedar](5-opa-and-cedar.md) — policy-as-code beyond raw Terraform/IAM JSON
6. [Control Tower Account Factory for Terraform (AFT)](6-control-tower-aft.md) — the "new landing zone" account-provisioning pattern this repo's manual account creation doesn't scale to
7. [CI/CD for Policy Deployment](7-cicd-for-policy.md) — turning the manual apply-and-verify workflow used throughout this repo into a pipeline

Not covered here: NIST/financial-services compliance mapping (niche), and the AWS Certified Security – Specialty certification (a credential to pursue separately, not a concept to learn from docs).
