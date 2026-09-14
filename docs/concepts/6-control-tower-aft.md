# Control Tower Account Factory for Terraform (AFT)

## Where this fits against what we built

Lesson 3 of this repo created four accounts with four `aws_organizations_account` resources, by hand, in one file. That's fine at the scale of a learning project. Job 2 explicitly mentions "Control Tower AFT pipelines (new landing zone) and hybrid Terraform/manual deployment (legacy landing zone)" — meaning: what this repo did (raw Terraform, no Control Tower) *is* the "legacy landing zone" half of that sentence. AFT is the other half, and it's worth understanding precisely because it's the thing this repo deliberately didn't build.

## What AFT actually is

Account Factory for Terraform is a Control-Tower-integrated pipeline (it **requires** Control Tower to already be enabled — it's not a standalone tool) that automates *new account provisioning* end-to-end, using Terraform instead of the Control Tower console/Account Factory UI. The pieces:

- A **request repo**: teams add a small Terraform-friendly config file (account email, name, target OU, tags) and open a PR — that's the entire "ask for a new account" interface.
- A **pipeline** (CodePipeline + CodeBuild under the hood) that, on merge, provisions the account through Control Tower's own account-vending process, then runs Terraform against it to apply standard baseline customizations.
- **Account customizations**: a separate repo/module pattern (`aft-account-customizations`) where you define what *every* new account should get automatically — baseline IAM roles, a default VPC layout, standard tags, maybe an initial permission boundary — so nobody hand-builds a new account from scratch the way lesson 3 did here.
- **Global customizations**: things applied to every account regardless of type (e.g., a standard CloudWatch log group, a security tooling role).

## Why this matters at 100+ accounts (the scale both JDs mention)

Four accounts, created once, by an engineer running `terraform apply` locally — completely reasonable, which is what this repo did. A hundred-plus accounts, requested continuously by many different teams, is a different problem: you need self-service (a PR, not a ticket to a platform team), consistency (every account gets the same non-negotiable baseline), and auditability (the request and its approval are both in git history). AFT is AWS's opinionated answer to that specific scaling problem — it's the account-provisioning equivalent of what this repo's SCP consolidation-by-theme was for guardrails: a pattern that stops working like the "one-off, by hand" version once the numbers get large.

## The direct contrast

| | This repo (lesson 3) | AFT |
|---|---|---|
| Requires Control Tower | No | Yes |
| How a new account is requested | Someone edits `3-accounts.tf` directly | A PR against a request repo, using a defined schema |
| Baseline setup for a new account | Whatever you manually add | Automatic, via account-customizations modules |
| Who can request an account | Whoever has repo access and AWS credentials | Any team via PR — no direct AWS access needed |
| Appropriate scale | A handful of accounts, one team | Dozens to hundreds of accounts, many teams |

## Likely interview questions

**Q: What's the difference between provisioning accounts with raw `aws_organizations_account` Terraform resources versus AFT?**
A: Raw resources (what this repo does) work fine at small scale with one team managing the code directly. AFT adds a self-service request layer (a PR-based interface non-platform teams can use), automatic baseline customization for every new account, and requires Control Tower underneath it — it's built for organizations provisioning accounts continuously and at volume, not a one-time setup.

**Q: Can you use AFT without Control Tower?**
A: No — AFT is built on top of Control Tower's account-vending mechanism; Control Tower has to already be enabled in the organization.

**Q: If a company has both an AFT-managed "new" landing zone and a legacy hand-built one (raw Terraform, no Control Tower), what's the practical implication for someone writing SCPs/RCPs across both?**
A: The policy content itself (the JSON) is identical either way — SCPs/RCPs don't care how the account was provisioned. What differs is *where* the Terraform code that attaches them lives and how it's deployed: through the AFT pipeline's customization repos for new-landing-zone accounts, versus direct `terraform apply` (or manual console work) against the legacy landing zone's existing accounts. That split is exactly why job 2 calls out "Terraform-compatible policy code" as a deliverable — the same policy artifact needs to be consumable by both deployment paths.
