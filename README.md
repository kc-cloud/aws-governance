# aws-governance

Learning repo for AWS Landing Zone concepts — multi-OU, multi-account, guardrails via
Service Control Policies (SCPs), Resource Control Policies (RCPs), and IAM permission
boundaries — built by hand in Terraform, one resource at a time.

This is a **manual, AWS-Organizations-based landing zone** (no AWS Control Tower):
every primitive is created explicitly so the mechanics are visible, rather than relying
on a managed service to set things up.

## How we work through this

One resource (or small group of related resources) at a time:

1. Ask for the next resource.
2. Get the Terraform code for just that piece, dropped into its corresponding file below.
3. `terraform plan` / `terraform apply` it yourself, and verify the result in the AWS console.
4. Once it's understood, move to the next resource.

## Lesson order / file map

All configuration lives flat in the repo root (no modules yet — that's a later lesson
once the basics click), representing the **management/payer account**, since AWS
Organizations resources can only be created from there.

| # | Concept | File |
|---|---|---|
| 1 | AWS Organization | `organization.tf` |
| 2 | Organizational Units (OUs) | `organizational_units.tf` |
| 3 | Member accounts | `accounts.tf` |
| 4 | Service Control Policies (SCPs) | `scp-1.tf`, `scp-2.tf`, ... (one file per SCP) |
| 5 | Resource Control Policies (RCPs) | `rcp.tf` |
| 6 | IAM permission boundaries | `permission_boundaries.tf` |

Shared boilerplate: `versions.tf` (Terraform/provider version pins), `providers.tf`
(AWS provider config), `variables.tf` (`region`, `profile`), `terraform.tfvars.example`
(copy to `terraform.tfvars` and fill in your own values — that file is gitignored).

## Getting started

```
cp terraform.tfvars.example terraform.tfvars   # then edit with your own region/profile
terraform init
terraform plan
```

State is stored remotely in S3 (`backend.tf`), using S3's native locking (`use_lockfile`)
so no DynamoDB table is needed. The bucket must exist before `terraform init`.
